import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  final Directory repoRoot = Directory.fromUri(
    File.fromUri(Platform.script).parent.parent.uri,
  );
  final Directory appDir = Directory('${repoRoot.path}/apps/learner_app');

  switch (args.first) {
    case 'backend':
      await _runCommand(_pythonCommand(), <String>[
        '-m',
        'uvicorn',
        'backend.api.main:app',
        '--host',
        '127.0.0.1',
        '--port',
        '8000',
        '--reload',
      ], workingDirectory: repoRoot.path);
      return;
    case 'health':
      await _checkHealth();
      return;
    case 'verify':
      await _verify(repoRoot, appDir);
      return;
    case 'run':
      if (args.length < 2) {
        stderr.writeln('Missing run target.');
        _printUsage();
        exitCode = 64;
        return;
      }
      await _flutterEntryPoint(
        mode: _FlutterMode.run,
        target: args[1],
        appDir: appDir,
        config: _readOption(args, '--config') ?? 'local',
      );
      return;
    case 'build':
      if (args.length < 2) {
        stderr.writeln('Missing build target.');
        _printUsage();
        exitCode = 64;
        return;
      }
      await _flutterEntryPoint(
        mode: _FlutterMode.build,
        target: args[1],
        appDir: appDir,
        config: _readOption(args, '--config') ?? 'local',
      );
      return;
    default:
      stderr.writeln('Unknown command: ${args.first}');
      _printUsage();
      exitCode = 64;
      return;
  }
}

enum _FlutterMode { run, build }

Future<void> _verify(Directory repoRoot, Directory appDir) async {
  await _runCommand(_npmCommand(), <String>[
    'run',
    'lint',
  ], workingDirectory: repoRoot.path);
  await _runCommand(_npmCommand(), <String>[
    'run',
    'typecheck',
  ], workingDirectory: repoRoot.path);
  await _runCommand(_npmCommand(), <String>[
    'run',
    'test',
  ], workingDirectory: repoRoot.path);
  await _runCommand(_pythonCommand(), <String>[
    'infra/scripts/validate_model_manifest.py',
    'apps/learner_app/web/model-manifest.json',
  ], workingDirectory: repoRoot.path);
  await _runCommand('flutter', <String>[
    'pub',
    'get',
  ], workingDirectory: appDir.path);
  await _runCommand('flutter', <String>[
    'analyze',
  ], workingDirectory: appDir.path);
  await _runCommand('flutter', <String>['test'], workingDirectory: appDir.path);
  await _runCommand('flutter', <String>[
    'build',
    'web',
    '--no-wasm-dry-run',
    '--dart-define-from-file=${_configPath(appDir, 'local')}',
  ], workingDirectory: appDir.path);
  await _runCommand('flutter', <String>[
    'build',
    'linux',
    '--dart-define-from-file=${_configPath(appDir, 'local')}',
  ], workingDirectory: appDir.path);
  await _runCommand('flutter', <String>[
    'build',
    'apk',
    '--debug',
    '--dart-define-from-file=${_configPath(appDir, 'local')}',
  ], workingDirectory: appDir.path);
}

Future<void> _flutterEntryPoint({
  required _FlutterMode mode,
  required String target,
  required Directory appDir,
  required String config,
}) async {
  final String configPath = _configPath(appDir, config);
  if (!File(configPath).existsSync()) {
    stderr.writeln('Missing runtime config: $configPath');
    exitCode = 66;
    return;
  }

  await _runCommand('flutter', <String>[
    'pub',
    'get',
  ], workingDirectory: appDir.path);

  final List<String> arguments = switch ((mode, target)) {
    (_FlutterMode.run, 'web') => <String>[
      'run',
      '-d',
      'web-server',
      '--web-hostname',
      '0.0.0.0',
      '--web-port',
      '8081',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'web-chrome') => <String>[
      'run',
      '-d',
      'chrome',
      '--web-renderer',
      'canvaskit',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'android') => <String>[
      'run',
      '-d',
      'android',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'ios') => <String>[
      'run',
      '-d',
      'ios',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'linux') => <String>[
      'run',
      '-d',
      'linux',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'macos') => <String>[
      'run',
      '-d',
      'macos',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.run, 'windows') => <String>[
      'run',
      '-d',
      'windows',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'web') => <String>[
      'build',
      'web',
      '--no-wasm-dry-run',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'android-debug') => <String>[
      'build',
      'apk',
      '--debug',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'android-release') => <String>[
      'build',
      'appbundle',
      '--release',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'ios') => <String>[
      'build',
      'ios',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'linux') => <String>[
      'build',
      'linux',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'macos') => <String>[
      'build',
      'macos',
      '--dart-define-from-file=$configPath',
    ],
    (_FlutterMode.build, 'windows') => <String>[
      'build',
      'windows',
      '--dart-define-from-file=$configPath',
    ],
    _ => throw ArgumentError('Unsupported ${mode.name} target: $target'),
  };

  await _runCommand('flutter', arguments, workingDirectory: appDir.path);
}

Future<void> _checkHealth() async {
  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.getUrl(
      Uri.parse('http://127.0.0.1:8000/v1/health'),
    );
    final HttpClientResponse response = await request.close();
    final String body = await utf8.decoder.bind(response).join();
    stdout.writeln(body);
    if (response.statusCode != 200) {
      exitCode = response.statusCode;
    }
  } finally {
    client.close(force: true);
  }
}

Future<void> _runCommand(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) async {
  stdout.writeln('\$ (${workingDirectory}) $executable ${arguments.join(' ')}');
  final Process process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  final int code = await process.exitCode;
  if (code != 0) {
    exit(code);
  }
}

String? _readOption(List<String> args, String name) {
  for (int i = 0; i < args.length; i++) {
    final String value = args[i];
    if (value == name && i + 1 < args.length) {
      return args[i + 1];
    }
    if (value.startsWith('$name=')) {
      return value.substring(name.length + 1);
    }
  }
  return null;
}

String _configPath(Directory appDir, String config) {
  return '${appDir.path}/config/runtime.$config.json';
}

String _pythonCommand() {
  return Platform.isWindows ? 'python' : 'python3';
}

String _npmCommand() {
  const String linuxVoltaNpm = '/home/efaz/.volta/bin/npm';
  if (Platform.isLinux && File(linuxVoltaNpm).existsSync()) {
    return linuxVoltaNpm;
  }
  return 'npm';
}

void _printUsage() {
  stdout.writeln('''
Melangua repo helper

Commands:
  dart tool/melangua.dart backend
  dart tool/melangua.dart health
  dart tool/melangua.dart verify
  dart tool/melangua.dart run web [--config local|emulators]
  dart tool/melangua.dart run web-chrome [--config local|emulators]
  dart tool/melangua.dart run android [--config local|emulators]
  dart tool/melangua.dart run ios [--config local|emulators]
  dart tool/melangua.dart run linux [--config local|emulators]
  dart tool/melangua.dart run macos [--config local|emulators]
  dart tool/melangua.dart run windows [--config local|emulators]
  dart tool/melangua.dart build web [--config local|emulators]
  dart tool/melangua.dart build android-debug [--config local|emulators]
  dart tool/melangua.dart build android-release [--config local|emulators]
  dart tool/melangua.dart build ios [--config local|emulators]
  dart tool/melangua.dart build linux [--config local|emulators]
  dart tool/melangua.dart build macos [--config local|emulators]
  dart tool/melangua.dart build windows [--config local|emulators]

Runtime configs:
  apps/learner_app/config/runtime.local.json
  apps/learner_app/config/runtime.emulators.json
  apps/learner_app/config/runtime.appcheck.example.json
''');
}

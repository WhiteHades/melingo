import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/models/model_manager_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'platform/window_size.dart';
import 'theme/tokens.dart';

enum AppTab {
  home('/home', 'Home', Icons.home_outlined, Icons.home),
  practice('/practice', 'Practice', Icons.mic_none_outlined, Icons.mic),
  stats('/stats', 'Stats', Icons.bar_chart_outlined, Icons.bar_chart),
  library('/library', 'Library', Icons.menu_book_outlined, Icons.menu_book),
  profile('/profile', 'Profile', Icons.person_outline, Icons.person),
  settings('/settings', 'Settings', Icons.settings_outlined, Icons.settings);

  const AppTab(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

GoRouter get appRouter => _router;

final GoRouter _router = GoRouter(
  initialLocation: AppTab.home.path,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return AdaptiveShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.home.path,
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.practice.path,
            builder: (BuildContext context, GoRouterState state) {
              return const PracticeScreen();
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.stats.path,
            builder: (BuildContext context, GoRouterState state) {
              return const StatsScreen();
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.library.path,
            builder: (BuildContext context, GoRouterState state) {
              return const LibraryScreen();
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.profile.path,
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: AppTab.settings.path,
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsScreen();
            },
          ),
          GoRoute(
            path: '/models',
            builder: (BuildContext context, GoRouterState state) {
              return const ModelManagerScreen();
            },
          ),
        ]),
      ],
    ),
  ],
);

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final AppWindowSize windowSize = resolveWindowSize(size);
    final List<AppTab> tabs = AppTab.values;

    if (windowSize == AppWindowSize.expanded) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              extended: true,
              onDestinationSelected: _onDestinationSelected,
              destinations: tabs
                  .map(
                    (AppTab tab) => NavigationRailDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.selectedIcon),
                      label: Text(tab.label),
                    ),
                  )
                  .toList(growable: false),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Melingo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Practice'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (windowSize == AppWindowSize.medium) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: tabs
                  .map(
                    (AppTab tab) => NavigationRailDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.selectedIcon),
                      label: Text(tab.label),
                    ),
                  )
                  .toList(growable: false),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: tabs
            .map(
              (AppTab tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

ThemeData melingoLightTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      elevation: AppElevation.low,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

ThemeData melingoDarkTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardTheme: CardThemeData(
      elevation: AppElevation.low,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      margin: const EdgeInsets.all(AppSpacing.md),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

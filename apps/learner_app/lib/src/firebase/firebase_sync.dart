import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding/onboarding_controller.dart';
import '../onboarding/onboarding_profile.dart';
import '../onboarding/onboarding_repository.dart';
import '../onboarding/sync_queue.dart';

abstract class CloudIdentityGateway {
  Future<String> ensureSignedIn();
}

class FirebaseIdentityGateway implements CloudIdentityGateway {
  FirebaseIdentityGateway({FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _resolvedAuth => _auth ?? FirebaseAuth.instance;

  @override
  Future<String> ensureSignedIn() async {
    final User? existing = _resolvedAuth.currentUser;
    if (existing != null) {
      return existing.uid;
    }

    final UserCredential credential = await _resolvedAuth.signInAnonymously();
    final User? user = credential.user;
    if (user == null) {
      throw StateError('firebase auth did not return a user');
    }
    return user.uid;
  }
}

abstract class CloudSyncGateway {
  Future<Map<String, dynamic>?> readProfile(String uid);

  Future<void> writeProfile(String uid, Map<String, dynamic> profile);

  Future<void> writePracticeEvent(String uid, SyncQueueItem item);
}

class FirestoreSyncGateway implements CloudSyncGateway {
  FirestoreSyncGateway({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _resolvedFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> readProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _resolvedFirestore.collection('profiles').doc(uid).get();
    return snapshot.data();
  }

  @override
  Future<void> writeProfile(String uid, Map<String, dynamic> profile) {
    return _resolvedFirestore.collection('profiles').doc(uid).set(
          profile,
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> writePracticeEvent(String uid, SyncQueueItem item) {
    final String eventId = _eventId(item);
    return _resolvedFirestore.collection('practice_events').doc(eventId).set(
      <String, dynamic>{
        'userId': uid,
        'type': item.type,
        'payload': item.payload,
        'createdAtIso': item.createdAtIso,
      },
      SetOptions(merge: true),
    );
  }

  String _eventId(SyncQueueItem item) {
    final Object? turnId = item.payload['turnId'];
    return '${item.type}_${turnId ?? 'global'}_${item.createdAtIso}';
  }
}

class FirebaseSyncService {
  FirebaseSyncService({
    required CloudIdentityGateway identityGateway,
    required CloudSyncGateway syncGateway,
    required SyncQueueRepository queueRepository,
    required OnboardingRepository onboardingRepository,
  })  : _identityGateway = identityGateway,
        _syncGateway = syncGateway,
        _queueRepository = queueRepository,
        _onboardingRepository = onboardingRepository;

  final CloudIdentityGateway _identityGateway;
  final CloudSyncGateway _syncGateway;
  final SyncQueueRepository _queueRepository;
  final OnboardingRepository _onboardingRepository;

  Future<int> syncAll() async {
    final String uid;
    try {
      uid = await _identityGateway.ensureSignedIn();
    } catch (_) {
      return 0;
    }

    final List<SyncQueueItem> queued = await _queueRepository.readAll();
    if (queued.isEmpty) {
      return 0;
    }

    final List<SyncQueueItem> remaining = <SyncQueueItem>[];
    int processed = 0;

    for (final SyncQueueItem item in queued) {
      try {
        switch (item.type) {
          case 'onboarding_profile_upsert':
            await _syncProfile(uid, item);
            break;
          case 'practice_event_append':
            await _syncGateway.writePracticeEvent(uid, item);
            break;
          default:
            remaining.add(item);
            continue;
        }

        processed += 1;
      } catch (_) {
        remaining.add(item);
      }
    }

    await _queueRepository.replaceAll(remaining);
    return processed;
  }

  Future<void> _syncProfile(String uid, SyncQueueItem item) async {
    final Map<String, dynamic>? remote = await _syncGateway.readProfile(uid);
    final String localUpdatedAt =
        item.payload['updatedAtIso'] as String? ?? item.createdAtIso;
    final String remoteUpdatedAt = remote?['updatedAtIso'] as String? ?? '';

    if (remoteUpdatedAt.isNotEmpty &&
        remoteUpdatedAt.compareTo(localUpdatedAt) > 0) {
      await _onboardingRepository.writeProfileOnly(
        OnboardingProfile.fromMap(remote!),
      );
      return;
    }

    await _syncGateway.writeProfile(
      uid,
      <String, dynamic>{
        ...item.payload,
        'userId': uid,
      },
    );
  }
}

final Provider<CloudIdentityGateway> cloudIdentityGatewayProvider =
    Provider<CloudIdentityGateway>((Ref ref) {
  return FirebaseIdentityGateway();
});

final Provider<CloudSyncGateway> cloudSyncGatewayProvider =
    Provider<CloudSyncGateway>((Ref ref) {
  return FirestoreSyncGateway();
});

final Provider<FirebaseSyncService> firebaseSyncServiceProvider =
    Provider<FirebaseSyncService>((Ref ref) {
  final CloudIdentityGateway identity = ref.watch(cloudIdentityGatewayProvider);
  final CloudSyncGateway gateway = ref.watch(cloudSyncGatewayProvider);
  final SyncQueueRepository queue = ref.watch(syncQueueRepositoryProvider);
  final OnboardingRepository onboarding =
      ref.watch(onboardingRepositoryProvider);
  return FirebaseSyncService(
    identityGateway: identity,
    syncGateway: gateway,
    queueRepository: queue,
    onboardingRepository: onboarding,
  );
});

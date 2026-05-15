import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/discovery/discovery_anchor_service.dart' as discovery;
import '../../chat/data/user_chat_prefs.dart';
import '../data/settings_repository.dart';
import '../domain/user_settings.dart';

/// Device-local notification and discovery preferences.
class SettingsCubit extends Cubit<UserSettings> {
  SettingsCubit(this._repository) : super(UserSettings.defaults);

  final SettingsRepository _repository;

  void load() {
    emit(_repository.load());
  }

  Future<void> _syncNotificationPrefs(UserSettings settings) async {
    await syncNotificationPrefsToFirestore(
      notifyChat: settings.notifyChat,
      notifyActivity: settings.notifyActivity,
      notifyLiveNearby: settings.notifyLiveNearby,
    );
  }

  Future<void> setNotifyActivity(bool value) async {
    final next = state.copyWith(notifyActivity: value);
    emit(next);
    await _repository.save(next);
    await _syncNotificationPrefs(next);
  }

  Future<void> setNotifyChat(bool value) async {
    final next = state.copyWith(notifyChat: value);
    emit(next);
    await _repository.save(next);
    await _syncNotificationPrefs(next);
  }

  Future<void> setNotifyLiveNearby(bool value) async {
    final next = state.copyWith(notifyLiveNearby: value);
    emit(next);
    await _repository.save(next);
    await _syncNotificationPrefs(next);
  }

  /// Pushes local prefs to Firestore after sign-in (best-effort).
  Future<void> syncNotificationPrefsFromState() async {
    await _syncNotificationPrefs(state);
  }

  Future<void> setUseGpsForDiscovery(bool value) async {
    final next = state.copyWith(useGpsForDiscovery: value);
    emit(next);
    await _repository.save(next);
  }

  SettingsRepository get repository => _repository;

  Future<LatLng> resolveDiscoveryAnchor() =>
      discovery.resolveDiscoveryAnchor(_repository);

  Future<LatLng> saveCurrentLocationAsAnchor() async {
    final gps = await discovery.fetchCurrentGpsPosition();
    if (gps == null) {
      throw StateError(
        'Location unavailable. Enable GPS and allow location permission.',
      );
    }
    if (!state.useGpsForDiscovery) {
      await _repository.saveDiscoveryAnchor(gps.latitude, gps.longitude);
    }
    emit(state.copyWith(discoveryAnchorEpoch: state.discoveryAnchorEpoch + 1));
    return gps;
  }
}

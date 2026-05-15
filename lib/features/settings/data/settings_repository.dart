import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../map/data/activity_geo.dart';
import '../domain/user_settings.dart';

const _kNotifyActivity = 'meet_radius_notify_activity';
const _kNotifyChat = 'meet_radius_notify_chat';
const _kNotifyLiveNearby = 'meet_radius_notify_live_nearby';
const _kUseGps = 'meet_radius_use_gps';
const _kAnchorLat = 'meet_radius_discovery_lat';
const _kAnchorLng = 'meet_radius_discovery_lng';

/// Persists [UserSettings] on device. Block list is stubbed until report/block ships.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  UserSettings load() {
    return UserSettings(
      notifyActivity: _prefs.getBool(_kNotifyActivity) ?? true,
      notifyChat: _prefs.getBool(_kNotifyChat) ?? true,
      notifyLiveNearby: _prefs.getBool(_kNotifyLiveNearby) ?? true,
      useGpsForDiscovery: _prefs.getBool(_kUseGps) ?? true,
    );
  }

  Future<void> save(UserSettings settings) async {
    await Future.wait([
      _prefs.setBool(_kNotifyActivity, settings.notifyActivity),
      _prefs.setBool(_kNotifyChat, settings.notifyChat),
      _prefs.setBool(_kNotifyLiveNearby, settings.notifyLiveNearby),
      _prefs.setBool(_kUseGps, settings.useGpsForDiscovery),
    ]);
  }

  LatLng loadDiscoveryAnchor() {
    final lat = _prefs.getDouble(_kAnchorLat);
    final lng = _prefs.getDouble(_kAnchorLng);
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return ActivityGeo.davaoAreaCenter;
  }

  Future<void> saveDiscoveryAnchor(double lat, double lng) async {
    await Future.wait([
      _prefs.setDouble(_kAnchorLat, lat),
      _prefs.setDouble(_kAnchorLng, lng),
    ]);
  }
}

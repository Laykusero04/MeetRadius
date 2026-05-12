import 'dart:math';

import 'package:latlong2/latlong.dart';

/// MVP map region (Davao area — matches feed copy until real geocoding).
abstract final class ActivityGeo {
  static const LatLng davaoAreaCenter = LatLng(7.065, 125.595);

  /// New activities get a random pin near the demo region so markers do not stack.
  static LatLng randomNearDavao() {
    final r = Random();
    return LatLng(
      davaoAreaCenter.latitude + (r.nextDouble() - 0.5) * 0.09,
      davaoAreaCenter.longitude + (r.nextDouble() - 0.5) * 0.09,
    );
  }

  /// Stable fallback for older docs without [latitude]/[longitude].
  static LatLng jitterFromActivityId(String activityId) {
    var h = 0;
    for (var i = 0; i < activityId.length; i++) {
      h = (h * 31 + activityId.codeUnitAt(i)) & 0x7fffffff;
    }
    final dx = ((h % 2000) - 1000) / 150000.0;
    final dy = (((h ~/ 2000) % 2000) - 1000) / 150000.0;
    return LatLng(
      davaoAreaCenter.latitude + dx,
      davaoAreaCenter.longitude + dy,
    );
  }
}

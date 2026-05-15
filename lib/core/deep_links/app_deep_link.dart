/// Parsed inbound link (custom scheme or https meetradius.app).
sealed class AppDeepLink {}

class ActivityDeepLink extends AppDeepLink {
  ActivityDeepLink(this.activityId);

  final String activityId;
}

class UserInviteDeepLink extends AppDeepLink {
  UserInviteDeepLink(this.inviterUserId);

  final String inviterUserId;
}

AppDeepLink? parseAppDeepLink(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  final path = uri.path.toLowerCase();

  if (scheme == 'meetradius') {
    if (host == 'activity' || path.startsWith('/activity')) {
      final id = uri.queryParameters['id'] ?? uri.queryParameters['activityId'];
      if (id != null && id.isNotEmpty) return ActivityDeepLink(id);
    }
    if (host == 'invite' || path.startsWith('/invite')) {
      final ref = uri.queryParameters['ref'];
      if (ref != null && ref.isNotEmpty) return UserInviteDeepLink(ref);
    }
  }

  if (scheme == 'https' || scheme == 'http') {
    if (host == 'meetradius.app' || host.endsWith('meetradius.app')) {
      if (path.contains('activity')) {
        final id = uri.queryParameters['id'] ?? uri.queryParameters['activityId'];
        if (id != null && id.isNotEmpty) return ActivityDeepLink(id);
      }
      if (path.contains('invite')) {
        final ref = uri.queryParameters['ref'];
        if (ref != null && ref.isNotEmpty) return UserInviteDeepLink(ref);
      }
    }
  }

  return null;
}

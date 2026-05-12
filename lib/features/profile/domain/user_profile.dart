import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profile from Firestore `users/{uid}` with auth fallbacks.
class UserProfile {
  const UserProfile({
    required this.email,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;

  /// e.g. "Member since Jan 2026" when [createdAt] is set.
  String get memberSinceLine {
    final dt = createdAt;
    if (dt == null) return 'MeetRadius member';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Member since ${months[dt.month - 1]} ${dt.year}';
  }

  /// Visible name: "First Last", or local part of email if names are empty.
  String get displayName {
    final f = firstName?.trim() ?? '';
    final l = lastName?.trim() ?? '';
    final combined = '$f $l'.trim();
    if (combined.isNotEmpty) return combined;
    final at = email.indexOf('@');
    if (at > 0) return email.substring(0, at);
    return email.isNotEmpty ? email : 'Member';
  }

  /// Up to two letters for [CircleAvatar].
  String get initials {
    final f = firstName?.trim() ?? '';
    final l = lastName?.trim() ?? '';
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    if (f.length >= 2) return f.substring(0, 2).toUpperCase();
    if (f.isNotEmpty) return f[0].toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  factory UserProfile.fromFirestoreMap(Map<String, dynamic> map) {
    final created = map['createdAt'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    }

    return UserProfile(
      email: (map['email'] as String?)?.trim() ?? '',
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      createdAt: createdAt,
    );
  }

  /// When there is no `users/{uid}` row yet: [User.displayName], email, metadata.
  factory UserProfile.fromAuthUser(User user) {
    final dn = user.displayName?.trim();
    String? first;
    String? last;
    if (dn != null && dn.isNotEmpty) {
      final parts = dn.split(RegExp(r'\s+'));
      first = parts.first;
      last = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }
    return UserProfile(
      email: user.email?.trim() ?? '',
      firstName: first,
      lastName: last,
      createdAt: user.metadata.creationTime,
    );
  }
}

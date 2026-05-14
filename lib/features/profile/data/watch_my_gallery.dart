import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/gallery_post.dart';

/// Image posts under `users/{uid}/gallery` (expects `imageUrl` string per doc).
///
/// Firestore rules should allow the signed-in user to read their own subcollection,
/// e.g. `match /users/{userId}/gallery/{postId} { allow read: if request.auth != null && request.auth.uid == userId; }`
Stream<List<GalleryPost>> watchMyGallery(String uid) {
  if (uid.isEmpty) {
    return Stream<List<GalleryPost>>.value(const []);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('gallery')
      .limit(100)
      .snapshots()
      .map((snap) {
        final list = <GalleryPost>[];
        for (final d in snap.docs) {
          final data = d.data();
          final url = data['imageUrl'] as String?;
          if (url == null || url.trim().isEmpty) continue;
          final created = data['createdAt'];
          DateTime? createdAt;
          if (created is Timestamp) {
            createdAt = created.toDate();
          }
          list.add(
            GalleryPost(id: d.id, imageUrl: url.trim(), createdAt: createdAt),
          );
        }
        list.sort((a, b) {
          final ta = a.createdAt;
          final tb = b.createdAt;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });
        return list;
      });
}

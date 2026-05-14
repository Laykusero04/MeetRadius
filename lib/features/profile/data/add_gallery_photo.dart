import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Adds a gallery doc under `users/{uid}/gallery` (expects `imageUrl`).
Future<void> addGalleryPhoto({required String imageUrl}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('You must be signed in to add a photo.');
  }
  final url = imageUrl.trim();
  if (url.isEmpty) {
    throw ArgumentError('Image URL is required.');
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('gallery')
      .add({
        'imageUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
}

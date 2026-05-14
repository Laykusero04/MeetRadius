/// A single image post in `users/{uid}/gallery/{postId}`.
class GalleryPost {
  const GalleryPost({required this.id, required this.imageUrl, this.createdAt});

  final String id;
  final String imageUrl;
  final DateTime? createdAt;
}

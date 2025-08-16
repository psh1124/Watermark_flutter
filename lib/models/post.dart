class Post {
  final int id;
  final String username;
  final String? imageUrl;
  final String caption;
  final int likeCount;
  final bool isLikedByUser;
  final DateTime createdAt;
  
  Post({
    required this.id,
    required this.username,
    this.imageUrl,
    required this.caption,
    required this.likeCount,
    required this.isLikedByUser,
    required this.createdAt,
  });
  
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      username: json['username'],
      imageUrl: json['image_url'],
      caption: json['caption'],
      likeCount: json['like_count'],
      isLikedByUser: json['is_liked_by_user'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
} 
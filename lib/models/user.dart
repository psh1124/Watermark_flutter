class User {
  final String username;
  final String? profileImageUrl;
  final String? bio;
  
  User({
    required this.username,
    this.profileImageUrl,
    this.bio,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profile_image_url': profileImageUrl,
      'bio': bio,
    };
  }
} 
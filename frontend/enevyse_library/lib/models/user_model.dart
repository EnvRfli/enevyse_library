class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String memberId;
  final String phone;
  final String address;
  final String profilePictureUrl;
  final List<String> preferredCategories;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.memberId = '',
    this.phone = '',
    this.address = '',
    this.profilePictureUrl = '',
    this.preferredCategories = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      memberId: json['member_id'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePictureUrl: json['profile_picture_url'] ?? '',
      preferredCategories: json['preferred_categories'] != null
          ? List<String>.from(json['preferred_categories'])
          : [],
    );
  }
}

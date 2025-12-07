class UserModel {
  final String userId;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? profilePicture;
  final String authMethod;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.userId,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.profilePicture,
    required this.authMethod,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      authMethod: json['auth_method'] ?? 'guest',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'auth_method': authMethod,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.guest() {
    return UserModel(
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      authMethod: 'guest',
      createdAt: DateTime.now(),
    );
  }
}

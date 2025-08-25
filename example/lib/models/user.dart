import 'profile.dart';

class User {
  final int id;
  final String name;
  final String? email;
  final Profile? profile;

  User({
    required this.id,
    required this.name,
    this.email,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile': profile?.toJson(),
    };
  }
}

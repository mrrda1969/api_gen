class Profile {
  final int id;
  final String? bio;
  final int? age;

  Profile({
    required this.id,
    this.bio,
    this.age,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'age': age,
    };
  }
}

class Users {
  late String uid;
  late String name;
  late String email;
  late String role;

  Users(
      {required this.uid,
      required this.name,
      required this.role,
      required this.email});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      uid: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

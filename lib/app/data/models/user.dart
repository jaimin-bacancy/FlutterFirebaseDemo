List<User> usersFromJson(dynamic str) =>
    List<User>.from(str.map((x) => User.fromJson(x)));

class User {
  final String uid;
  final String name;
  final String email;

  const User({
    required this.name,
    required this.uid,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      uid: json['uid'] as String,
      email: json['email'] as String,
    );
  }
}

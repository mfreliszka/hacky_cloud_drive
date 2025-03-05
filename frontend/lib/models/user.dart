class User {
  final String email;
  // You can include additional user fields such as id, name, token, etc.

  User({ required this.email });
  
  // Example: factory constructor to create a User from JSON data (if needed)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json['email']);
  }

  // Example: convert User to JSON (for sending to backend, if needed)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      // add other fields here
    };
  }
}

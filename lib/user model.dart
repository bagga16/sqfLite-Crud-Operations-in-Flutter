// class User {
//   int id;
//   String username;
//   String password;

//   User({required this.id, required this.username, required this.password});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'username': username,
//       'password': password,
//     };
//   }

//   factory User.fromMap(Map<String, dynamic> map) {
//     return User(
//       id: map['id'],
//       username: map['username'],
//       password: map['password'],
//     );
//   }

// }

// Update the User class
import 'package:sqf_lite/authentication.dart';

class User {
  int? id; // Make the ID nullable
  String username;
  String password;

  User({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}

// Update the _saveUserData method
Future<void> _saveUserData(String username, String password) async {
  // Implement the logic to save the user data in the database
  DatabaseHelper dbHelper = DatabaseHelper();
  List<User> users = await dbHelper.getUsers();

  // Find the maximum ID in the existing users
  int maxId = users.isNotEmpty
      ? users.map((user) => user.id!).reduce((a, b) => a > b ? a : b)
      : 0;

  // Create a new user with a unique ID
  User user = User(id: maxId + 1, username: username, password: password);

  // Save the new user in the database
  await dbHelper.insertUser(user);
}

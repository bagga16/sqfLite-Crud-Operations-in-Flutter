class NotesModel {
  int? id;
  String title;
  int age;
  String description;
  final String email;
  NotesModel(
      {this.id,
      required this.title,
      required this.age,
      required this.email,
      required this.description});
  NotesModel.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        age = res['age'],
        title = res['title'],
        description = res['description'],
        email = res['email'];
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'age': age,
      'title': title,
      'email': email,
      'description': description,
    };
  }
}

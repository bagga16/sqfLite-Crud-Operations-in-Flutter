import 'package:flutter/material.dart';
import 'package:sqf_lite/Notes.dart';
import 'package:sqf_lite/db_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 58, 187, 243),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Employee Data'),
      ),
      body: Column(children: [
        Expanded(
          child: FutureBuilder(
              future: notesList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            showDialogForUpdate(context, snapshot.data![index]);
                          },
                          // onLongPress: () {
                          //   dbHelper!.update(NotesModel(
                          //       id: snapshot.data![index].id!,
                          //       title: 'new',
                          //       age: 23,
                          //       email: '@gmail.com',
                          //       description: 'about employe'));
                          //   setState(() {
                          //     notesList = dbHelper!.getNotesList();
                          //   });
                          // },
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete_forever),
                            ),
                            onDismissed: (DismissDirection direction) {
                              setState(() {
                                dbHelper!.delete(snapshot.data![index].id!);
                                notesList = dbHelper!.getNotesList();
                                snapshot.data!.remove(snapshot.data![index]);
                              });
                            },
                            key: ValueKey<int>(snapshot.data![index].id!),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.only(left: 17, right: 14),
                                title:
                                    Text(snapshot.data![index].title.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        )),
                                subtitle: Text(snapshot.data![index].description
                                    .toString()),
                                trailing: Column(
                                  children: [
                                    Text('Age',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        )),
                                    Text(snapshot.data![index].age.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
        //mian colum
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await dbHelper!.insert(NotesModel(
            title: 'employ1',
            age: 20,
            email: 'liaba@gmail.com',
            description: 'Student of BSIT',
          ));

          // After inserting, update the notesList with the new data
          var updatedNotesList = await dbHelper!.getNotesList();
          setState(() {
            notesList = Future.value(updatedNotesList);
          });

          print('Data inserted');

          // dbHelper!
          //     .insert(NotesModel(
          //         title: 'employ1',
          //         age: 20,
          //         email: 'liaba@gmail.com',
          //         description: 'Student of BSIT'))
          //     .then((value) {
          //   setState(() {
          //     notesList = dbHelper!.getNotesList();
          //   });
          //   print('Data inserted');
          // }).onError((error, stackTrace) {
          //   print('Something went wrong');
          // });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showDialogForUpdate(BuildContext context, NotesModel notesModel) async {
    TextEditingController titleController =
        TextEditingController(text: notesModel.title);
    TextEditingController ageController =
        TextEditingController(text: notesModel.age.toString());
    TextEditingController descriptionController =
        TextEditingController(text: notesModel.description);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                notesModel.title = titleController.text;
                notesModel.age = int.tryParse(ageController.text) ?? 0;
                notesModel.description = descriptionController.text;

                var result = await dbHelper!.update(notesModel);

                setState(() {
                  notesList = dbHelper!.getNotesList();
                });

                // Handle the update result if needed
                if (result != null && result > 0) {
                  // Show success message or handle accordingly
                } else {
                  // Show failure message or handle accordingly
                }

                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Database _database;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final FocusNode _imageFocusNode = FocusNode();
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'items.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY,
            text TEXT,
            imagePath TEXT
          )
        ''');
      },
    );

    _refreshItemList();
  }

  Future<void> _refreshItemList() async {
    final List<Map<String, dynamic>> maps = await _database.query('items');

    setState(() {
      items = List.generate(
        maps.length,
        (index) => Item(
          id: maps[index]['id'],
          text: maps[index]['text'],
          imagePath: maps[index]['imagePath'],
        ),
      );
    });
  }

  Future<void> _addItem() async {
    await _database.insert(
      'items',
      {
        'text': _textController.text,
        'imagePath': _imageController.text,
      },
    );

    _textController.clear();
    _imageController.clear();
    _imageFocusNode.unfocus();

    _refreshItemList();
  }

  Future<void> _updateItem(BuildContext context, Item item) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Item'),
          content: Column(
            children: [
              TextField(
                controller: _textController..text = item.text,
                decoration: InputDecoration(labelText: 'Text'),
              ),
              TextField(
                controller: _imageController..text = item.imagePath,
                decoration: InputDecoration(labelText: 'Image Path'),
                focusNode: _imageFocusNode,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Item updatedItem = Item(
                  id: item.id,
                  text: _textController.text,
                  imagePath: _imageController.text,
                );

                await _database.update(
                  'items',
                  updatedItem.toMap(),
                  where: 'id = ?',
                  whereArgs: [item.id],
                );

                _textController.clear();
                _imageController.clear();
                _imageFocusNode.unfocus();

                Navigator.of(context).pop();
                _refreshItemList();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(Item item) async {
    await _database.delete(
      'items',
      where: 'id = ?',
      whereArgs: [item.id],
    );

    _refreshItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter SQLite Demo'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].text),
            leading: CircleAvatar(
              backgroundImage: FileImage(File(items[index].imagePath)),
            ),
            onTap: () => _updateItem(context, items[index]),
            onLongPress: () => _deleteItem(items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(),
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Item {
  final int id;
  final String text;
  final String imagePath;

  Item({
    required this.id,
    required this.text,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
    };
  }
}

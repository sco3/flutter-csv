import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Convert'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _file = "";
  final TextEditingController _txt = TextEditingController();

  Future<List<List<dynamic>>> parseCsvFile(Uint8List bytes) async {
    Stream<List<int>> input = Stream.value(bytes);

    // Use the stream to read, decode, and parse the CSV data
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: "\n", fieldDelimiter: ","))
        .toList();

    return fields;
  }

  void showFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      PlatformFile file = result.files.single;

      setState(() {
        _file = file.name;
      });
      Uint8List? bytes = file.bytes;
      List<List> data = await parseCsvFile(bytes);
      String txt = "";
      for (List row in data) {
        txt += '$row\n';
      }

      setState(() {
        _txt.text = txt;
      });
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: showFile,
                  tooltip: 'Pick File',
                  child: const Icon(Icons.file_open),
                ),
                const SizedBox(width: 10),
                const Text('File:'),
                const SizedBox(width: 10),
                Text(_file),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _txt,
                  maxLines: null,
                  minLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

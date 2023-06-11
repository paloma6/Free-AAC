import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:free_aac/imageToSpeechCell.dart';
import 'package:path_provider/path_provider.dart';

class SavedSentencesPage extends StatefulWidget {
  const SavedSentencesPage({super.key});

  @override
  State<SavedSentencesPage> createState() => _SavedSentencesPageState();
}

class _SavedSentencesPageState extends State<SavedSentencesPage> {
  Directory? applicationDirectory;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      setState(() {
        applicationDirectory = dir;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (applicationDirectory == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    File file = File(applicationDirectory!.path + "/sentences.json");
    late final List<dynamic> sentences;

    if (!file.existsSync()) {
      file.createSync();
      sentences = [];
    } else {
      try {
        sentences = jsonDecode(file.readAsStringSync());
      } catch (e) {
        sentences = [];
      }
    }

    List<Widget> sentencesWidgets = sentences.map((sentenceJSON) {
      List<dynamic> sentence = jsonDecode(sentenceJSON);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(255, 200, 211, 221),
                  blurRadius: 10,
                  offset: Offset(0, 0))
            ],
          ),
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            spacing: 10.0,
            direction: Axis.horizontal,
            children: sentence.map((cell) {
              // Map<String, dynamic> cell = jsonDecode(cellJSON);
              print(cell);
              late Widget cellWidget;
              if (cell["type"] == "word") {
                cellWidget = SizedBox(
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 214, 235, 252),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cell["word"],
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                );
              } else if (cell["type"] == "ImageToSpeechCell") {
                cellWidget = SizedBox(
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: ImageToSpeechCell.fromJson(cell),
                  ),
                );
              } else {
                cellWidget = Text("Error");
              }
              return cellWidget;
            }).toList(),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: Center(
        child: ListView(
          children: sentencesWidgets,
        ),
      ),
    );
  }
}

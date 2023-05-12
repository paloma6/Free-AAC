import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:free_aac/imageToSpeechCell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _controller;
  FlutterTts flutterTts = FlutterTts();

  // a screen is array of cells, where each cell is a little square with a icon and
  // a associated word or category of words. A cell is represented by a imageToSpeechCell
  // instance, and a screen is represented by a list of imageToSpeechCell instances.
  // Each cell have either an associated word, that will be read when we click on it,
  // or an associated list of children, that will be displayed when we click on it.
  //
  // The screen path is the path of the current screen. It is a list of integers,
  // where each integer is the index of the cell in the previous screen.
  // Simply said, if we click on the first cell of the first screen and if this cell
  // has children, the screen path will be [0]. Then if we click on the second cell
  // of the second screen, the screen path will be [0, 1].
  List<int> _currentScreenPath = [];

  List<ImageToSpeechCell>? _topCells;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    flutterTts.setLanguage("en-US");
    // loadImageToSpeechMetadata();
    loadImageToSpeechMetadata();
  }

  loadImageToSpeechMetadata() async {
    String data = await rootBundle.loadString("image-to-speech.json");
    List<dynamic> decoded = jsonDecode(data);

    setState(() {
      _topCells =
          decoded.map((cell) => ImageToSpeechCell.fromJson(cell)).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playTTS(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    //While the imageToSpeechMetadata is loading, display a loading screen
    if (_topCells == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the imageToSpeechMetadata is loaded, display the main screen
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // The text field where the user can type the text to be read
            TextField(
              controller: _controller,
              onSubmitted: playTTS,
            ),
            //The back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_currentScreenPath.isNotEmpty) {
                      setState(() {
                        _currentScreenPath.removeLast();
                      });
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              ],
            ),
            // The grid view containing the cells for the image to speech
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                children: _currentScreenPath
                    .fold<List<ImageToSpeechCell>>(
                      _topCells!,
                      (previousCells, cellIndex) =>
                          previousCells[cellIndex].children!,
                    )
                    .asMap() // asMap().entries is a dart hack to access indices
                    .entries
                    .map(
                      (entry) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (entry.value.children != null) {
                              _currentScreenPath.add(entry.key);
                            } else {
                              playTTS(entry.value.name);
                            }
                          });
                        },
                        child: entry.value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

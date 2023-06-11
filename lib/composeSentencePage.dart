import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:free_aac/imageToSpeechCell.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ComposeSentencePage extends StatefulWidget {
  const ComposeSentencePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<ComposeSentencePage> createState() => _ComposeSentencePageState();
}

class _ComposeSentencePageState extends State<ComposeSentencePage> {
  late final applicationDirectory;
  FlutterTts flutterTts = FlutterTts();
  late TextEditingController _controller;
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

  List currentSentence = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = "\u200b";
    loadImageToSpeechMetadata();
    getApplicationDocumentsDirectory().then((directory) {
      applicationDirectory = directory;
    });
  }

  loadImageToSpeechMetadata() async {
    String data = await rootBundle.loadString("assets/image-to-speech.json");
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
    if (!kIsWeb &&
        !Platform.isAndroid &&
        !Platform.isIOS &&
        !Platform.isMacOS &&
        !Platform.isWindows) {
      // TTS is not supported by this platform.
      print("TTS is not supported by this platform. The text was: $text");
      return;
    }
    flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  void playSentenceTTS(List sentence) async {
    if (!kIsWeb &&
        !Platform.isAndroid &&
        !Platform.isIOS &&
        !Platform.isMacOS &&
        !Platform.isWindows) {
      // TTS is not supported by this platform.
      print(
          "TTS is not supported by this platform. The text was: ${sentence.join(" ").trim()}");
      return;
    }
    String text = "";
    for (var word in sentence) {
      if (word is String) {
        // ignore: prefer_interpolation_to_compose_strings
        text += word + " ";
      } else if (word is ImageToSpeechCell) {
        // ignore: prefer_interpolation_to_compose_strings
        text += word.name + " ";
      }
    }
    await flutterTts.speak(text);
  }

  void saveSentence(List sentence) async {
    List wordsStringified = [];

    for (var word in sentence) {
      if (word is String) {
        wordsStringified.add('{"word": "$word", "type": "word"}');
      } else if (word is ImageToSpeechCell) {
        wordsStringified.add(
            '{"cell_name": "${word.name}", "cell_image_name": "${word.imageName}", "type": "ImageToSpeechCell"}');
      }
    }

    //Reading current file
    File file = File(applicationDirectory.path + "/sentences.json");

    List<dynamic> decoded;
    if (file.existsSync()) {
      try {
        decoded = jsonDecode(file.readAsStringSync());
      } catch (e) {
        decoded = [];
      }
    } else {
      decoded = [];
    }

    //Adding the new sentence
    String newSentenceJson = "[${wordsStringified.join(", ")}]";
    decoded.add(newSentenceJson);

    //Writing the new file
    await file.writeAsString(jsonEncode(decoded));
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(255, 200, 211, 221),
                          blurRadius: 10,
                          offset: Offset(0, 0))
                    ]),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      onSubmitted: (text) {
                        if (text != "\u200b") {
                          setState(() {
                            currentSentence.add(text);
                          });
                        }

                        _controller.text =
                            "\u200b"; // the Zero-width character.
                        //moves the cursor after the zero-width character
                        _controller.selection = const TextSelection.collapsed(
                          offset: 1,
                        );
                        playSentenceTTS(currentSentence);
                      },
                      onChanged: (value) {
                        if (value.endsWith(" ")) {
                          setState(() {
                            currentSentence.add(value.trim());

                            // Adds the Zero-width character.
                            // It is a hacky workaround to make the text field empty, but still be able
                            // to detect the erase event. There is no other way to detect the erase in
                            // an empty text field. See this https://medium.com/super-declarative/why-you-cant-detect-a-delete-action-in-an-empty-flutter-text-field-3cf53e47b631
                            //moves the cursor after the zero-width space character
                            _controller.text = "\u200b";

                            //moves the cursor after the zero-width character
                            _controller.selection =
                                const TextSelection.collapsed(
                              offset: 1,
                            );

                            //play the word :
                            playSentenceTTS([value.trim()]);
                          });
                        } else if (value
                                .isEmpty && //Here if it is empty that means that the user pressed erase on a empty text field
                            currentSentence.isNotEmpty) {
                          setState(() {
                            if (currentSentence.last is String) {
                              _controller.text =
                                  "\u200b${currentSentence.last}";
                            } else {
                              _controller.text = "\u200b";
                            }
                            //moves the cursor at the end of the textfield
                            _controller.selection = TextSelection.collapsed(
                              offset: _controller.text.length,
                            );
                            currentSentence.removeLast();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: Wrap(
                          spacing: 10,
                          children: [
                            // Displays the already written pictures and words
                            for (var word in currentSentence)
                              if (word is String)
                                Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 214, 235, 252),
                                      borderRadius: BorderRadius.circular(4.0)),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(word),
                                )
                              else if (word is ImageToSpeechCell)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: word,
                                  ),
                                ),
                          ],
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () => saveSentence(currentSentence),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => playSentenceTTS(currentSentence),
                        )
                      ],
                    )
                  ],
                ),
              ),
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
            // The Wrap containing the cells for the image to speech
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                direction: Axis.horizontal,
                children: _currentScreenPath
                    .fold<List<ImageToSpeechCell>>(
                      _topCells!,
                      (previousCells, cellIndex) =>
                          previousCells[cellIndex].children!,
                    )
                    .asMap() // asMap().entries is a dart hack to access indices
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (entry.value.children != null) {
                                      _currentScreenPath.add(entry.key);
                                    } else {
                                      playTTS(entry.value.name);
                                      if (_controller.text != "" &&
                                          _controller.text != "\u200b") {
                                        currentSentence.add(_controller.text);
                                        _controller.text = "\u200b";
                                        //moves the cursor after the zero-width character
                                        _controller.selection =
                                            const TextSelection.collapsed(
                                          offset: 1,
                                        );
                                      }
                                      currentSentence.add(entry.value);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: entry.value,
                                ),
                              ),
                            ),
                            Text(
                              entry.value.name,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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

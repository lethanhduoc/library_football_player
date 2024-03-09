import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _wordsSpoken = "";
  bool search = false;
  String toList = "";
  File? saveImage;
  final TextEditingController contentController = TextEditingController();
  Uint8List webImage = Uint8List(8);

  Future<void> pickImage() async {
    if (!kIsWeb) {
      final ImagePicker picker0 = ImagePicker();
      XFile? image = await picker0.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          saveImage = selected;
        });
      } else {
        print("No image has been picked");
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          saveImage = File('a');
          _uploadData(webImage);
        });
        print(image);
      } else {
        print("No image has been picked");
      }
    } else {
      print("Something went wrong");
    }
  }

  Future<void> _uploadData(Uint8List imageChoose) async {
    try {
      String base64Image = base64Encode(imageChoose);

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/get_embedding'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data['embedding']);
      } else {
        throw Exception('Failed to get embedding');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    setState(() {});
  }

  // void _startListening() async {
  //   await _speechToText.listen(onResult: _onSpeechResult);
  // }

  // void _stopListening() async {
  //   await _speechToText.stop();
  //   setState(() {});
  // }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    // final TextEditingController controllerSpeak =
    //     TextEditingController(text: _wordsSpoken);
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(
          top: search || saveImage != null ? 20 : screenSize.height / 3),
      alignment: search == false || saveImage == null
          ? Alignment.center
          : Alignment.topLeft,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/background-bong-da.jpg"),
              fit: BoxFit.cover)),
      child: Column(
        children: [
          search || saveImage != null
              ? Container()
              : Text(
                  "Library Football Player",
                  style: GoogleFonts.playball(
                      fontSize: 45,
                      color: const Color.fromARGB(255, 127, 206, 22)),
                ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: screenSize.width / 3,
            // padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      offset: const Offset(0, 40),
                      blurRadius: 80)
                ]),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: search ? screenSize.width / 4.5 : screenSize.width / 4,
                  padding: const EdgeInsets.only(left: 8),
                  child: _isListening
                      ? Text(
                          _wordsSpoken,
                          style: TextStyle(fontSize: 14),
                        )
                      : TextField(
                          // ignore: unnecessary_null_comparison
                          controller: contentController,
                          decoration: InputDecoration(
                              suffixIconColor:
                                  const Color.fromARGB(255, 6, 233, 97),
                              prefixIcon: IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(Icons.search),
                              ),
                              // hintText: _speechToText.isListening
                              //     ? 'Chúng tôi đang lắng nghe...'
                              //     : 'Nhập tên cầu thủ mà bạn muốn tìm thông tin...',
                              hintStyle: const TextStyle(fontSize: 14),
                              border: InputBorder.none),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    search || saveImage != null
                        ? IconButton(
                            onPressed: () {
                              _isListening = false;
                            },
                            icon: const Icon(Icons.keyboard),
                            color: Colors.lightBlue,
                          )
                        : Container(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isListening = true;
                        });
                        // _speechToText.isListening
                        //     ? _stopListening()
                        //     : _startListening();
                      },
                      icon: const Icon(
                        Icons.mic_none_outlined,
                        color: Colors.lightBlue,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        pickImage();
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      color: Colors.lightBlue,
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          search || saveImage != null
              ? Container()
              : ElevatedButton(
                  style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(150, 50)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 43, 191, 232)),
                  ),
                  onPressed: () {
                    setState(() {
                      search = true;
                    });
                    print(contentController.text);
                    print(_wordsSpoken);
                    print(_isListening);
                  },
                  child: Text("Tìm kiếm",
                      style: GoogleFonts.sarabun(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
          saveImage != null
              ? Container(
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: screenSize.width / 2,
                          height: screenSize.height - 200,
                          child: kIsWeb
                              ? Image.memory(
                                  webImage,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  saveImage!,
                                  fit: BoxFit.contain,
                                ))
                    ],
                  ),
                )
              : Container()
        ],
      ),
    ));
  }
}

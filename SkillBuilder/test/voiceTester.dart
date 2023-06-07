/*
implementation of VoiceAPI listen() function w/ a button
implementation of VoiceAPI speak() function w/ button(?)
 */
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'VoiceAPI.dart';

class VoiceApp extends StatefulWidget {
  @override
  _VoiceAppState createState() => _VoiceAppState();
}

class _VoiceAppState extends State<VoiceApp> {
  final VoiceAPI _voiceAPI = VoiceAPI();
  String? voiceInput;
  List<String> localeNames = [];
  var currentLocaleId;
  bool _showLanguages = false;

  Future<void> _voiceInit() async {
    await _voiceAPI.init();
    localeNames = await _voiceAPI.getLocales();
    currentLocaleId = _voiceAPI.getCurrentLocale();
  }

  Future<void> _listenText() async {
    String? text = await _voiceAPI.listen();
    setState(() {
      voiceInput = text;
      print("Text: $text");
    });
  }

  Future<void> _requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission not granted');
    }
  }

  Future<void> _speakText(String text) async {
    await _voiceAPI.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Speech to Text Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
//#######################################################
            children: <Widget>[
              _buildMicButton(),
              SizedBox(height: 20),
              Text(
                voiceInput ?? '',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              _buildRepeatButton(),
              _buildLanguagesButton(),
              if (_showLanguages) _buildLangSwitch(),

            ],
//#######################################################
          ),
        ),
      ),
    );
  }


  Widget _buildListenButton() {
    return ElevatedButton(
      onPressed: () async {
        if (!_voiceAPI.isInitialized()){
          await _voiceInit();
        }
        await _requestMicrophonePermission();
        await _listenText();
      },
      child: Text('Tap to Speak'),
    );
  }

  Widget _buildMicButton() {
    return ElevatedButton(
      onPressed: () async {
        if (!_voiceAPI.isInitialized()){
          await _voiceInit();
        }
        await _requestMicrophonePermission();
        await _listenText();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic),
          SizedBox(width: 10),
          Text('Speak'),
        ],
      ),
    );
  }


  Widget _buildRepeatButton() {
    return ElevatedButton(
      child: Text("Tap to Repeat!"),
      onPressed: () {
        if (voiceInput != null) {
          _speakText("Hello! You said... $voiceInput");
        }
      },
    );
  }

  Widget _buildLanguagesButton() {
    return ElevatedButton(
      child: Text("Languages!"),
      onPressed: () async {
        if (!_voiceAPI.isInitialized()){
          await _voiceInit();
        }
        setState(() {
          _showLanguages = !_showLanguages; // toggle flag
        });
      },
    );
  }

  Widget _buildLangSwitch() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            Text('Language: '),
            DropdownButton<String>(
              onChanged: (selectedVal) {
                setState(() {
                  _voiceAPI.changeLanguage(selectedVal!);
                  currentLocaleId = selectedVal;
                });
              },
              value: currentLocaleId,
              items: localeNames
                  .map(
                    (name) => DropdownMenuItem(
                  value: name,
                  child: Text(name),
                ),
              ).toList(),
            ),
          ],
        ),
      ],
    );
  }



}
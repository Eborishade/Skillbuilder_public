/*
 * Voice to Text & Text to Voice APIs
 */
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class VoiceAPI {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String? localeID;
  bool initted = false;
  List<LocaleName> _localeNames = [];



  /**Speech to Text Functions*/
  Future<void> init() async {
    if (!initted) {
      if (await _speech.initialize()) {
        var systemLocale = await _speech.systemLocale(); //current locale
        localeID = systemLocale?.localeId ?? ''; //prints en_US
      }

      //language
      await _flutterTts.setLanguage(localeID ?? "en-US");
      await _flutterTts.setLanguage("en-US");

      //voice
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5); //range 0.0-1.0 [slowest -> fastest]
      //await _flutterTts.setVoice({"name": "Karen", "locale": "en-US"});

      initted = true;
    }
  }


  bool isInitialized(){
    return initted;
  }

  /**Speech to Text Functions*/

  Future<String?> listen() async {
    Completer<String?> completer = Completer<String?>();
    await _speech.listen(
      partialResults: false,
      cancelOnError: true,
      pauseFor: Duration(seconds: 4),
      localeId: localeID,
      onResult: (result) {
        String text = result.recognizedWords;
        print("Results: $text");
        completer.complete(text);
      },
    );

    return completer.future;
  }

  void stopListen() => _speech.stop(); //called implicitly with onResult


  /**Text to Speech Functions */

  Future<void> speak(String text) async {
    await _flutterTts.speak("$text");
  }

  Future<void> speakGB(String text) async {
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setPitch(1.0);
    List<dynamic> voices = await _flutterTts.getVoices;
    // await _flutterTts.setVoice(voices[1]);
    await _flutterTts.speak(text);
  }

  void stopSpeak() => _flutterTts.stop();

  void reset() {
    stopListen();
    stopSpeak();
  }


  /** Change Language/Locale */

  Future<void> changeLanguage(String l) async {
    localeID = l;
    print("New Locale: $localeID");
  }

  Future<List<dynamic>> getLang() async => await _flutterTts.getLanguages;
  String? getCurrentLocale() => localeID;

  Future<List<String>> getLocales() async {
    List<String> locs = <String>[];
    List<dynamic> haystack = await _speech.locales();

    for (dynamic needle in haystack){
      String locale = needle.localeId;
      locs.add(locale);
    }
    return locs;
  }


/*
     Usage:
     var locales = await VoiceAPI.getLocale()
      // Some UI or other code to select a locale from the list
      // resulting in an index, selectedLocale
      var selectedLocale = locales[selectedLocale];
      changeLanguage(selectedLocale.localeId)
   */


/* // Potential Language Menu Widget
  var localeNames = await VoiceAPI.getLocale();
  var currentLocaleId = VoiceAPI.getCurrentLocale();
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
      Row(
      children: [
      Text('Language: '),
      DropdownButton<String>(
        onChanged: (selectedVal) => VoiceAPI.changeLanguage(selectedVal),
        value: currentLocaleId,
        items: localeNames
            .map(
              (localeName) => DropdownMenuItem(
                value: localeName.localeId,
                child: Text(localeName.name),
              ),
            ).toList(),
         ),
        ],
       ),
      ),
    );
  }
 */
}
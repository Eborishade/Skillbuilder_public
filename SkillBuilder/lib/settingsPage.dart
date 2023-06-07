import 'dart:async';
import 'package:SkillBuilder/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'chatAPI.dart';
import 'homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class settingsPage extends StatefulWidget {
  @override
  _settingsPageState createState() => _settingsPageState();
}
class ChangeApiKeyScreen extends StatefulWidget {
  @override
  _ChangeApiKeyScreenState createState() => _ChangeApiKeyScreenState();
}
class _ChangeApiKeyScreenState extends State<ChangeApiKeyScreen> {
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change API Key"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: "Enter new API key",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String newApiKey = _apiKeyController.text.trim();
                ChatAPI.updateApiKey(newApiKey);
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}


  Future<String> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey') ?? '';
  }

  _saveApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
  }


class _settingsPageState extends State<settingsPage> {
  bool valNotify1 = true;
  bool valNotify2 = false;
  bool valNotify3 = false;
  double _currentValue = 0.8; //Used for temperature slider

  @override
  void initState(){
    _loadSettings();
    _loadApiVersion();
    _loadApiTemperature();
  }

  _saveSettings() async {
    SharedPreferences settingsPrefs = await SharedPreferences.getInstance();
    settingsPrefs.setBool('darkModeSetting', valNotify1);
  }

  _loadSettings() async {
    SharedPreferences settingsPrefs = await SharedPreferences.getInstance();
    setState(() {
      valNotify1 = settingsPrefs.getBool('darkModeSetting')!;
    });
  }

  onChangeFunction1(bool newValue1){
    setState((){
      valNotify1 = newValue1;
    });
    _saveSettings();
  }

  onChangeFunction2(bool newValue2){
    setState((){
      valNotify2 = newValue2;
    });
  }

  onChangeFunction3(bool newValue3){
    setState((){
      valNotify3 = newValue3;
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: valNotify1 ? Colors.grey[900]: Colors.white,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontFamily: "Courier New", color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          onPressed: () {
            Navigator.push(  //TODO - change this to .pop in order to preserve the on screen chat, but it wont load settings properly
              context,
              MaterialPageRoute(builder: (context) => OpenAIScreen()),  //OpenAIScreen(valNotify1: valNotify1) - possibly needed to send the boolean to home page
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 40),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.deepOrange,
                ),
                SizedBox(width:10),
                Text("Advanced", style: TextStyle(fontFamily: "Courier New", color: valNotify1 ? Colors.white: Colors.grey[900], fontSize: 22, fontWeight: FontWeight.bold))
              ],
            ),
            Divider(height: 20, thickness: 1),
            SizedBox(height: 10),
            buildClearChatHistorySetting(context, "Clear Chat History"),
            buildClearImageHistorySetting(context, "Clear Image History"),
            buildChangeApiKey(context, "Change API Key"),
            buildChangeApiTemp(context, "Change Temperature"),
            buildGptVersion(context, "Change GPT version"),
            //buildAccountOption(context, "Privacy and Security"),
            SizedBox(height: 40),
            Row(
              children: [
                Icon(Icons.volume_up_outlined, color: Colors.deepOrange),
                SizedBox(width: 10),
                Text("Preferences", style: TextStyle(fontFamily: "Courier New", color: valNotify1 ? Colors.white: Colors.grey[900], fontSize: 22, fontWeight: FontWeight.bold))
              ],
            ),
            Divider(height: 20, thickness: 1),
            SizedBox(height: 10),
            buildNotificationOption("Theme Dark", valNotify1, onChangeFunction1),
            // buildNotificationOption("Test2", valNotify2, onChangeFunction2),
            // buildNotificationOption("Test3", valNotify3, onChangeFunction3)
          ],
        ),
      ),
    );
  }


  Padding buildNotificationOption(String title, bool value, Function onChangeMethod){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontFamily: "Courier New",
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
          )),
          Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                activeColor: Colors.deepOrange,
                trackColor: Colors.grey,
                value: value,
                onChanged: (bool newValue) {
                  onChangeMethod(newValue);
                },
              )
          )
        ],
      ),
    );
  }


  GestureDetector buildAccountOption(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Option 1"),
                Text("option 2")
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }


  /**Changing API Version**/
  String? tempVersion = "";
  _saveApiVersion() async {
    SharedPreferences apiVersionPrefs = await SharedPreferences.getInstance();
    apiVersionPrefs.setString('apiVersionPref', versionChosen!);
  }

  _loadApiVersion() async {
    SharedPreferences apiVersionPrefs = await SharedPreferences.getInstance();
    setState(() {
      tempVersion = apiVersionPrefs.getString('apiVersionPref');
    });
    if(tempVersion != null){
      versionChosen = tempVersion;
      ChatAPI.updateApiVersion(versionChosen!);
    }
  }

  String? versionChosen = "text-davinci-003";
  String originalVersion = "text-davinci-003";
  List versionOptions = ["text-davinci-003", "text-davinci-002", "gpt-3.5-turbo"];
  GestureDetector buildGptVersion(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Please select which version of ChatGPT you would like to use"),
          StatefulBuilder(
          builder: (context, state){
                return DropdownButton(
                  hint: Text("Select Version:"),
                    value: versionChosen,
                    items: versionOptions.map((valueItem){
                      return DropdownMenuItem(value: valueItem, child: Text(valueItem));
                      }).toList(),
                    onChanged: (newValue){
                      state((){

                      });
                      setState(() {
                      versionChosen = newValue.toString();
                      });
                    });
          })
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    print("CONFIRMED THE NEW version");
                    ChatAPI.updateApiVersion(versionChosen!);
                    originalVersion = versionChosen!;
                    _saveApiVersion();
                    Navigator.of(context).pop();
                  },
                  child: Text("Confirm")
              ),
              TextButton(
                  onPressed: () {
                    versionChosen = originalVersion;
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }




  GestureDetector buildChangeApiKey(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangeApiKeyScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  /**Changing API Temperature**/

  int? tempTemperature = 0;
  _saveApiTemperature() async {
    SharedPreferences apiTempPrefs = await SharedPreferences.getInstance();
    apiTempPrefs.setInt('apiTempPref', selectedIndex!);
  }

  _loadApiTemperature() async {
    SharedPreferences apiTempPrefs = await SharedPreferences.getInstance();
    setState(() {
      tempTemperature = apiTempPrefs.getInt('apiTempPref');
    });
    if(tempTemperature != null){
      selectedIndex = tempTemperature!;
      ChatAPI.updateApiTemperature(divisionValues[tempTemperature!]);
    }
  }

 final List<double> divisionValues = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
  int selectedIndex = 7;
  int originalSelectedIndex = 7;
  GestureDetector buildChangeApiTemp(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Please Select a temperature"),
                Text("Current API Temperature " + divisionValues[selectedIndex].toString(), style: TextStyle(fontFamily: "Courier New")),
                StatefulBuilder(
                  builder: (context, state){
                    return Slider(value: selectedIndex.toDouble(),
                      min: 0,
                      max: divisionValues.length - 1,
                      divisions: divisionValues.length - 1,
                      label: divisionValues[selectedIndex].toString(),
                      activeColor: Colors.deepOrange,
                      inactiveColor: Colors.grey,
                      thumbColor: Colors.deepOrange,
                      onChanged: (value) {
                        state((){

                        });
                        setState((){
                          selectedIndex = value.toInt();
                          _currentValue = divisionValues[selectedIndex];
                        });
                      },
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    originalSelectedIndex = selectedIndex;
                    print("CONFIRMED THE NEW TEMPERATURE");
                    ChatAPI.updateApiTemperature(_currentValue);
                    _saveApiTemperature();
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes")
              ),
              TextButton(
                  onPressed: () {
                    selectedIndex = originalSelectedIndex;
                    print("CLOSED THE WINDOW");
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }



  GestureDetector buildClearChatHistorySetting(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Are you sure you would like to clear your saved chat history?")
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    print("CONFIRMED THE CLEAR");
                    _clearChatHistory();
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes")
              ),
              TextButton(
                  onPressed: () {
                    print("CLOSED THE WINDOW");
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }


  GestureDetector buildClearImageHistorySetting(BuildContext context, String title){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Are you sure you would like to clear your saved images?")
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    print("CONFIRMED THE CLEAR");
                    _clearLastImages();
                    Navigator.of(context).pop();
                  },
                  child: Text("Yes")
              ),
              TextButton(
                  onPressed: () {
                    print("CLOSED THE WINDOW");
                    Navigator.of(context).pop();
                  },
                  child: Text("Close")
              )
            ],
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontFamily: "Courier New",
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: valNotify1 ? Colors.grey[400]: Colors.grey[700]
            )),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }




  /**Clearing chat history function**/
  Future<void> _clearChatHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final chatHistoryFile = File('${directory.path}/lastChats.txt');
    if (!await chatHistoryFile.exists()) {
      await chatHistoryFile.create();
    }
    await chatHistoryFile.writeAsString('');
  }


  /**Clearning last images function**/
  void _clearLastImages() async {
    // Get the documents directory
    Directory directory = await getApplicationDocumentsDirectory();

    // Get a list of all the image files in the directory
    List<FileSystemEntity> files = directory.listSync();
    List<File> imageFiles = [];
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.png')) {
        File(file.path).delete();
      }
    }

    // Sort the list of image files by creation time (newest first)
    imageFiles.sort((a, b) => b.lastAccessedSync().compareTo(a.lastAccessedSync()));

    // Return the last 20 images
  }

}

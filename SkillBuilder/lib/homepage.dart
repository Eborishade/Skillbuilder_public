import 'dart:async';
import 'dart:convert';
import 'package:SkillBuilder/settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chatAPI.dart';
import 'package:permission_handler/permission_handler.dart';
import 'VoiceAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'landingPage.dart';
import 'youtubeAPI.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/** Chat History SIDEBAR **/
/** last chat**/
class LastChatsScreen extends StatefulWidget {
  @override
  _LastChatsScreenState createState() => _LastChatsScreenState();
}
class LastImagesTab extends StatefulWidget {
  @override
  _LastImagesTabState createState() => _LastImagesTabState();
}

class _LastImagesTabState extends State<LastImagesTab> {
  bool darkMode = true;

  _loadSettings() async {
    SharedPreferences settingsPrefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = settingsPrefs.getBool('darkModeSetting') ?? true;
    });
  }
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImageList( ),
    );
  }

  Widget _buildImageList() {
    // Get the list of image files from the documents directory
    return Scaffold(
        backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          title: Text("Last Images", style: TextStyle(fontFamily: "Courier New", color: Colors.white, fontSize: 22)),
          backgroundColor: Colors.deepOrange,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
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
      body: FutureBuilder<List<File>>(
      future: _getLastImages(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // If there are images, display them in a ListView
          List<File> imageFiles = snapshot.data!;
          return ListView.builder(
            itemCount: imageFiles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  // Share the image when the user long presses on it
                  Share.shareFiles([imageFiles[index].path]);
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Image.file(imageFiles[index]),
                ),
              );
            },
          );
        } else {
          // If there are no images, display a message
          return Center(
            child: Text('No images to display'),
          );
        }
      },
    ));
  }

  Future<List<File>> _getLastImages() async {
    // Get the documents directory
    Directory directory = await getApplicationDocumentsDirectory();

    // Get a list of all the image files in the directory
    List<FileSystemEntity> files = directory.listSync();
    List<File> imageFiles = [];
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.png')) {
        imageFiles.add(file);
      }
    }

    // Sort the list of image files by creation time (newest first)
    imageFiles.sort((a, b) => b.lastAccessedSync().compareTo(a.lastAccessedSync()));

    // Return the last 20 images
    return imageFiles.take(20).toList();
  }
}
class _LastChatsScreenState extends State<LastChatsScreen> {
  bool darkMode = true;

  _loadSettings() async {
    SharedPreferences settingsPrefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = settingsPrefs.getBool('darkModeSetting') ?? true;
    });
  }

  List<String> _chatHistory = [];
  List<String> _promptAndResponses = [];

  Future<void> _loadChatHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final chatHistoryFile = File('${directory.path}/lastChats.txt');
    if (await chatHistoryFile.exists()) {
      final content = await chatHistoryFile.readAsString();
      final List<String> chatHistory = List<String>.from(jsonDecode(content));
      setState(() {
        _chatHistory = chatHistory;
        _chatHistory.addAll(_promptAndResponses);
      });
    } else {
      setState(() {
        _chatHistory = _promptAndResponses;
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final chatHistoryFile = File('${directory.path}/lastChats.txt');
    final encodedData = jsonEncode(_chatHistory);
    await chatHistoryFile.writeAsString(encodedData);
  }

  void _updateChatHistory() {
    setState(() {
      _chatHistory.addAll(_promptAndResponses);
      _saveChatHistory();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Last Chats',
          style: TextStyle(fontFamily: "Courier New", color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _chatHistory.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              _chatHistory[index],
              style: TextStyle(
                  fontFamily: "Courier New",
                  color: darkMode ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    _chatHistory.addAll(_promptAndResponses);
    _saveChatHistory();
  }
}/** End Chat History Sidebar **/


/** Main Page **/

class OpenAIScreen extends StatefulWidget {
  @override
  _OpenAIScreenState createState() => _OpenAIScreenState();
}

class _OpenAIScreenState extends State<OpenAIScreen> {
  /** Loading settings ON MAIN PAGE */
  bool darkMode = true;

  _loadSettings() async {
    SharedPreferences settingsPrefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = settingsPrefs.getBool('darkModeSetting')!;
    });
  }

  @override
  void initState(){
    _loadSettings();
    _loadLandingPage();
    _loadApiVersion();
    _loadApiTemperature();
  }
  /** End of loading settings on main page */

  /** Loading ApiVersion */
  String? tempVersion = "";
  _loadApiVersion() async {
    SharedPreferences apiVersionPrefs = await SharedPreferences.getInstance();
    setState(() {
      tempVersion = apiVersionPrefs.getString('apiVersionPref');
    });
    if(tempVersion != null){
      ChatAPI.updateApiVersion(tempVersion!);
      print("LOADED API VERSION:");
      print(tempVersion);
    }
  }
  /** End of Loading ApiVersion */

  /**Loading API Temperature**/

  int? tempTemperature = 0;
  final List<double> divisionValues = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];

  _loadApiTemperature() async {
    SharedPreferences apiTempPrefs = await SharedPreferences.getInstance();
    setState(() {
      tempTemperature = apiTempPrefs.getInt('apiTempPref');
    });
    if(tempTemperature != null){
      ChatAPI.updateApiTemperature(divisionValues[tempTemperature!]);
      print("LOADED API TEMPERATURE");
      print(divisionValues[tempTemperature!]);
    }

  }
  /**End of Loading API Temperature**/


  /** Loading landingPage Bool*/

  bool ?openLandingPage = true; //loading landing page only for the first time

  _loadLandingPage() async {
    SharedPreferences landingPagePref = await SharedPreferences.getInstance();
    setState(() {
      openLandingPage = landingPagePref.getBool('loadLandingPage');
    });
    print("OPENLANDING PAGE BOOL: ");
    print(openLandingPage);

    if(openLandingPage != false){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OpenLandingPage()),
      );
    }
  }


  //Input Control
  final TextEditingController _inputController = TextEditingController();
  StreamController<String> _responseStreamController = StreamController<String>();

  //GPT Control
  List<String> _promptAndResponses = [];
  bool _isSendingMessage = false;

  //Voice Control
  final VoiceAPI _voiceAPI = VoiceAPI();
  String? voiceInput;
  bool _voiceChatEnabled = false;

  //Image Control
  bool _stopButtonPressed = false;
  List<Map<String, dynamic>> _imagePromptsAndImages = [];

  //Video Control
  final YtAPI ytApi = YtAPI();
  bool _prompted = false;
  bool _enableVideo = false;


  /** Voice Functions */
  //Initialize Voice Functions
  Future<void> _voiceInit() async {
    await _voiceAPI.init();
  }

  //convert voice input to text
  Future<void> _listenText() async {
    _voiceAPI.reset(); //stops all previous listening/speaking
    String? text = await _voiceAPI.listen();

    setState(() {
      voiceInput = text;
      print("Text: $text");
    });
  }

  //convert text to voice output
  Future<void> _speakText(String text) async {
    _voiceAPI.reset();
    await _voiceAPI.speak(text);
  }

  //cancel all listening/speaking
  void _cancelVoice(){
    _voiceAPI.reset();
  }

  //Get Microphone Permission - Warning: ANDROID ONLY
  Future<void> _requestMicrophonePermission() async {
    if ((await Permission.microphone.request().isGranted)) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission not granted');
    }
  }
  /** End Voice Functions */


  /** Chat Functions */
  //to save chats locally
  Future<void> _saveChatHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final chatHistoryFile = File('${directory.path}/lastChats.txt');
    if (!await chatHistoryFile.exists()) {
      await chatHistoryFile.create();
    }
    final encodedData = jsonEncode(_promptAndResponses);
    await chatHistoryFile.writeAsString(encodedData);
  }



  // GPT API Call
  String _lastResponse = '';

  Future<void> _getResponse(String input) async {
    try {
      setState(() {
        _isSendingMessage = true;
      });

      String prompt = 'You: $input\n';
      _responseStreamController.sink.add('$prompt\nGenerating response...\n');

      // Generate response with context
      String response = await ChatAPI.generateResponse(input);

      // Store the current response as the last response
      _lastResponse = response;

      // Set up controller with initial text
      TextEditingController controller = TextEditingController(text: "");
      _responseStreamController.sink.add(controller.text);

      // Add a delay between each character typed
      const int delay = 10;
      bool isStopButtonPressed = false; // Add flag to track stop button
      for (int i = 0; i < response.length && !isStopButtonPressed; i++) {
        await Future.delayed(Duration(milliseconds: delay));
        controller.text += response[i];
        _responseStreamController.sink
            .add('$prompt\nSkillBuilder: ${controller.text}');

        // Check if stop button is pressed
        if (_stopButtonPressed) {
          isStopButtonPressed = true;
          _promptAndResponses.add("Response Generation Stopped");
        }
      }

      // Store the prompt and response in the list if stop button is not pressed
      if (!isStopButtonPressed) {
        _promptAndResponses.add(prompt);
        _promptAndResponses.add('SkillBuilder: $response');
        //save chat to hsitory
        await _saveChatHistory();
      }

      // Hide the keyboard
      FocusScope.of(context).unfocus();
      // Add the latest item in the list to the stream
      _responseStreamController.sink.add(_promptAndResponses.last);
      // Clear input field
      _inputController.clear();
    } catch (e) {
      _responseStreamController.sink.add('Failed to generate response\n');
      print(e);
    } finally {
      setState(() {
        _isSendingMessage = false;
        _stopButtonPressed = false;
        _prompted = true;
      });
    }
  }


  //cleanup functions
  void _clearChat() {
    _promptAndResponses.clear();
    _responseStreamController.sink.add('');
  }

  @override
  void dispose() {
    _responseStreamController.close();
    super.dispose();
  }
  /** End Chat Functions */


  /** Image Generator Functions **/

  //Determine whether to generate image or text
  Future<void> promptChecker(prompt) async{
    if (prompt.contains("imagine")) {
      await _getImage(prompt);
      _inputController.clear();
    }
    else{
      _getResponse(prompt);
    }
  }

  // DALL-E API Call
  Future<void> _getImage(prompt) async {
    String input = prompt;
    int numImages = 6;
    bool _isSendingImageRequest = false;
    try {
      setState(() {
        _isSendingImageRequest = true;
      });

      String prompt = 'Image prompt: $input\n';
      _responseStreamController.sink.add('$prompt\nGenerating image...\n');

      // Generate image with input prompt
      List<Uint8List> imageBytes = (await ChatAPI.generateImages(input, numImages));

      // Display the image
      if (imageBytes != null) {
        setState(() {
          _promptAndResponses.add(prompt);
          _promptAndResponses.add('Image generated successfully');
        });

        // Call the display method to the image
        _showGeneratedImage(prompt, imageBytes);

      } else {
        _responseStreamController.sink.add('Failed to generate image\n');
      }

    } catch (e) {
      _responseStreamController.sink.add('Failed to generate image\n');
      print(e);
    } finally {
      setState(() {
        _isSendingImageRequest = false;
      });
    }
  }
  Future<File> saveImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _showGeneratedImage(String prompt, List<Uint8List> imageBytesList) async {
    List<Image> imageList = [];
    for (Uint8List bytes in imageBytesList) {
      // Create an Image widget from the image bytes
      Image image = Image.memory(bytes, fit: BoxFit.cover);
      imageList.add(image);

      // Save the image to the device
      await saveImage(bytes);
    }

    // Add the Image widgets and prompt to the state
    setState(() {
      _imagePromptsAndImages.add({
        'prompt': prompt,
        'images': imageList
      });
    });
  }


  void _handleStopButtonPressed() {
    bool pressed = false;
    _stopButtonPressed = true;
  }

/** End Image Generator Functions **/


/**MAIN BUILD FUNC **/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900]: Colors.white,
      // set the background color to dark grey
      appBar: AppBar(
        title: Text(
          "SkillBuilder",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Courier New",
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        backgroundColor: Colors.deepOrange,
        // Add a hamburger menu button to the app bar
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Open the drawer when the user clicks the hamburger menu
                Scaffold.of(context).openDrawer();
                FocusScope.of(context).unfocus();
              },
            );
          },
        ),
      ),

      /** Add a Drawer widget to show the settings screen */
      drawer: Drawer(
        backgroundColor: darkMode ? Colors.grey[900]: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Courier New",
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
            ),

            ListTile(
              title: Text('User Settings', style: TextStyle(color: darkMode ? Colors.white: Colors.grey[900]),),
              onTap: () {
                // Navigate to the Settings screen when the user clicks on the menu item
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => settingsPage()),
                );
              },
            ),
            ListTile(
              title: Text('Last Chats', style: TextStyle(color: darkMode ? Colors.white: Colors.grey[900])),
              onTap: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LastChatsScreen()),
                  );
                }
            ),
            ListTile(
                title: Text('Last Images', style: TextStyle(color: darkMode ? Colors.white: Colors.grey[900])),
                onTap: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LastImagesTab()),
                  );
                }
            )

          ],
        ),
      ),


      body: Column(
        children: <Widget>[

          //Chat History
          _buildChatHistory(),

         // if (_prompted)
          //  _buildVideoResults(),
          //Bottom Row Options: Voice or Text Chat
          SizedBox(
            height: 180,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color:  darkMode ? Colors.grey[800] : Colors.grey[400],
                borderRadius: BorderRadius.circular(10.0),
              ),

              /**Toggle Bottom Row Options: Voice Chat or Text Chat */
              child: Column(
                children: [
                 // _buildToggleVoiceButton(),

                  if (_voiceChatEnabled)
                    _buildVoiceChat()
                  else
                    _buildTextChat(),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }//END MAIN BUILD FUNCTION

/**WIDGETS**/


  /** Image Generation */

  /** Stop button for Image Generation */
  Widget _buildStopGenButton(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: IconButton(
        icon: Icon(Icons.stop_circle),
        color: Colors.deepOrange,
        onPressed: _handleStopButtonPressed,
      ),
    );
  }

  /** Video Generation */
  //search for relevant videos based on prompt and display results
  Widget _buildVideoResults(){
    String lastPrompt;
    String str = _promptAndResponses.lastWhere(
            (element) =>
            element.startsWith('You:'),
        orElse: () => "");
    if (str != ""){
      lastPrompt = str.replaceAll(RegExp("You:"), '');
    } else {
      lastPrompt = str;
    }

    return Expanded(
      child: SearchResultsWidget(
          ytApi: ytApi,
          searchTerm: lastPrompt
      ),
    );
  }

  //enable video display
  Widget _videoToggle(){
    return ToggleButtons(
      isSelected: [_enableVideo],
      onPressed: (int index) {
        setState(() {
          _enableVideo = !_enableVideo;
        });
      },
      children: [
        Icon(Icons.video_library),
      ],
    );
  }

  /** Main Toggle */

  /** Toggle between Voice Chat and Text Chat */
  Widget _buildToggleVoiceButton(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _voiceChatEnabled = !_voiceChatEnabled;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepOrange,
        shape: CircleBorder(),
        padding: EdgeInsets.all(5),
      ),
      child: Icon(
        _voiceChatEnabled ? Icons.west : Icons.mic,
        color: Colors.white,
        size: 18.0,
      ),
    );
  }


  /**Voice Chat Build Functions **/

  /** Build VoiceChat */
  //Bottom row replaced with voice chat features: speak/listen, repeat, text chat
  Widget _buildVoiceChat(){
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleVoiceButton(),

          _buildListenButton(),

          _buildCancelButton(),

          _buildRepeatButton(),

        ],
      ),
    );
  }

  /** Start listening, convert voice to text, send to gpt, then speak response*/
  Widget _buildListenButton() {
    bool isListening = false; // Add a boolean variable to track whether the button is currently listening or not

    return ElevatedButton(
      onPressed: () async {
        await _requestMicrophonePermission();
        await _voiceInit();
        await _listenText();
        if (voiceInput != null){
          await _getResponse(voiceInput!);
          await _speakText(_promptAndResponses.last);
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepOrange,
        shape: CircleBorder(),
        padding: EdgeInsets.all(5),
      ),
      child: const Icon(
        Icons.mic_none,
        color: Colors.white,
        size: 50.0,
      ),

      onLongPress: () { // Add a long press event to toggle the isListening variable
        setState(() {
          isListening = !isListening;
        });
      },
    );
  }

  /** Cancel all speaking/listening */
  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        _cancelVoice();
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepOrange,
        shape: CircleBorder(),
        padding: EdgeInsets.all(5),
      ),
      child: const Icon(
        Icons.stop,
        color: Colors.white,
        size: 50.0,
      ),
    );
  }

  /** Repeat last thing said by Skillbuilder (not user input)*/
  Widget _buildRepeatButton() {
    return ElevatedButton(
      onPressed: () {
        if (voiceInput != null) {
          _speakText("Oh, I said... ${_promptAndResponses.last}");//FIX
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepOrange,
        shape: CircleBorder(), // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0),)
        padding: EdgeInsets.all(5),
      ),
      child: const Icon(
        Icons.replay,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }


  /**Text Chat Build Functions **/

  /** Build Text Chat  */
  //Bottom Row: text input, send btn, clear btn
  Widget _buildTextChat() {
    return Column(
      children: [
        Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //_buildToggleVoiceButton(),
            _buildInputArea(),
            SizedBox(width: 16),
            _buildSendButton(),
          ],
        ),
        Row (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildToggleVoiceButton(),
            _buildStopGenButton(),
            _buildClearButton(),
            // add widgets for the second row here
          ],
        ),
      ],
    );
  }

  /**Input Text Bar */
  Widget _buildInputArea(){
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(right: 5.0, top: 23),
        child: TextField(
          maxLength: 1000,
          controller: _inputController,
          decoration: InputDecoration(
            counterStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Courier New",
            ),
            hintText: "Enter a question",
            contentPadding: EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 10.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.deepOrange, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepOrange.shade700,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          maxLines: null,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Courier New",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

  }

    /**Send Input Button */
  Widget _buildSendButton() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.0),
          child: IconButton(
            icon: Icon(Icons.send_outlined),
            color: Colors.deepOrange,
            // set the color to grey when a response is being generated
            onPressed: _isSendingMessage
                ? null
                : () {
              if (_inputController.text.isNotEmpty) {
                promptChecker(_inputController.text);
              }
            }, // disable the button when a response is being generated
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.0),
          child: IconButton(
            icon: Icon(Icons.keyboard_arrow_down),
            color: Colors.deepOrange,
            onPressed: () {
              // Collapse the keyboard
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ],
    );
  }


  /**Clear button */
  Widget _buildClearButton(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: IconButton(
        icon: Icon(Icons.delete_sweep_outlined),
        color: Colors.deepOrange,
        onPressed: _clearChat,
      ),
    );
  }

  Widget _buildChatHistory() {
    return Flexible(
      child: StreamBuilder<String>(
        stream: _responseStreamController.stream,
        builder: (context, snapshot) {
          String data = snapshot.data ?? '';
          List<String> chatHistory = [..._promptAndResponses];
          // Add the latest item in the list if it's not already in the chat history
          if (!chatHistory.contains(data) && data.isNotEmpty) {
            chatHistory.add(data);
          }

          return ListView.builder(
            itemCount: chatHistory.length,
            itemBuilder: (BuildContext context, int index) {
              String message = chatHistory[chatHistory.length - index - 1];
              bool isPrompt = message.startsWith('You:');
              bool isResponse = message.startsWith('SkillBuilder:');
              bool showShareButton = isResponse;

              if (_imagePromptsAndImages.any((element) => element['prompt'] == message)) {
                int imageIndex = _imagePromptsAndImages.indexWhere((element) => element['prompt'] == message);
                List<Image> imageList = _imagePromptsAndImages[imageIndex]['images'];

                return Column(
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontFamily: "Courier New",
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(imageList.length, (index) {
                        return GestureDetector(
                          child: Hero(
                            tag: '$message-$index',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: imageList[index],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text(message),
                                ),
                                body: Center(
                                  child: Hero(
                                    tag: message,
                                    child: imageList[index],
                                  ),
                                ),
                              );
                            }));
                          },
                        );
                      }),
                    ),
                  ],
                );
              } else {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: isPrompt ? Colors.deepOrange : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column (
                          children: [
                            Text(
                              message,
                              style: TextStyle(
                                fontFamily: "Courier New",
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            //Button to enable video display area
                            if (isResponse)
                              _videoToggle(),
                            if (_enableVideo && isResponse)
                              SizedBox(
                                height: 200,
                                    child: SearchResultsWidget(
                                        ytApi: ytApi,
                                        searchTerm: _promptAndResponses.lastWhere(
                                            (element) =>
                                            element.startsWith('You:'),
                                        orElse: () => "").replaceAll('You:', '')
                                    ),
                              ),
                          ]
                        )
                      ),
                      if (showShareButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              icon: Icon(Icons.account_tree),
                              color: Colors.deepOrange,
                              onPressed: () {
                                String lastResponse = _promptAndResponses.lastWhere(
                                        (element) =>
                                        element.startsWith(message),
                                    orElse: () => "");
                                if (lastResponse != "") {
                                  Share.share(lastResponse);
                                }
                              }),
                        ),
                    ],
                  ),
                );
              }
            },
            reverse: true,
          );
        },
      ),
    );
  }
}
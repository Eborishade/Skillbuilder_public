import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:googleapis/chat/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';



class OpenLandingPage extends StatefulWidget {
  @override
  _OpenLandingPageScreenState createState() => _OpenLandingPageScreenState();
}

class _OpenLandingPageScreenState extends State<OpenLandingPage> {
  bool loadLandPage = false;
  final String termsAndConditions = '''
  Terms and Conditions


Welcome to Skillbuilder! By accessing or using the software and services provided by Skillbuilder, you acknowledge and agree to be
bound by these terms and conditions. Please read these terms carefully before using the services of Skillbuilder.\n\n

1.Accuracy and Reliability

Skillbuilder is designed to provide information and facilitate decision-making processes. However, the accuracy and reliability
of the information provided by Skillbuilder are not guaranteed, and the application may contain errors or inaccuracies. Users
should not rely solely on the information provided by Skillbuilder, and should always independently verify any information they
receive.\n\n

2.Not Professional Advice

The information and materials provided by Skillbuilder are for general information purposes only and are not intended to be a
substitute for professional advice. You should not rely upon the information or materials provided by Skillbuilder as a basis for
making any business, legal, or other decisions. You should seek independent advice from a professional in the relevant field
before making any such decision.\n\n

3.Limitation of Liability

Skillbuilder shall not be responsible for any direct, indirect, incidental, special, or consequential damages arising out of the use
of the services provided by Skillbuilder. In no event shall Skillbuilder's total liability to you for all damages, losses, and causes
of action exceed the amount paid by you, if any, for accessing the services of Skillbuilder.\n\n

4.Warranties and Liabilities

Skillbuilder is provided "as is," without warranty of any kind, express or implied, including but not limited to the implied
warranties of merchantability, fitness for a particular purpose, and non-infringement. The developer is not responsible for any
direct, indirect, incidental, special, or consequential damages arising from the use of Skillbuilder, and users assume all risk and
liability associated with using the application.\n\n

5.Modifications to Terms and Services
Skillbuilder reserves the right, in its sole discretion, to modify or replace any of these terms or services at any time. Your
continued use of Skillbuilder's services following the posting of any changes to these terms constitutes acceptance of those
changes.\n\n

6.Third-Party Links

Skillbuilder may provide links to third-party websites or resources. You acknowledge and agree that Skillbuilder is not
responsible or liable for the availability or accuracy of such websites or resources, and does not endorse and is not responsible
or liable for any content, advertising, products, or other materials on or available from such websites or resources. You further
acknowledge and agree that Skillbuilder shall not be responsible or liable, directly or indirectly, for any damage or loss caused
or alleged to be caused by or in connection with the use of or reliance on any such content, goods, or services available on or
through any such website or resource.\n\n

7.Data Privacy and Security

Skillbuilder may collect and process user data, including audio data and personal information. Users should be aware that data
transmitted over the internet may not be secure, and Skillbuilder developers cannot guarantee the security of user data. The user
is responsible for protecting the privacy of their data, and the developer is not responsible for any unauthorized access or use of
user data. You may revoke Skillbuilder's access to your microphone at any time through your device's privacy settings. Please
note that some features of Skillbuilder may not work as intended without access to your device's microphone.\n\n

8.Termination
Skillbuilder reserves the right, in its sole discretion, to terminate or suspend your access to all or any part of the services
provided by Skillbuilder, with or without notice and with or without cause.\n\n

9.Governing Law

These terms and conditions shall be governed by and construed in accordance with the laws of the state in which Skillbuilder is
based, without giving effect to any principles of conflicts of law. You agree that any action arising out of or related to the
services provided by Skillbuilder or these terms shall be brought exclusively in the courts located in the state in which
Skillbuilder is based.\n\n

These terms and conditions, together with any additional terms to which you may agree when using certain features of Skillbuilder,
constitute the entire agreement between you and Skillbuilder with respect to the use of the services provided by Skillbuilder. By using
Skillbuilder, you acknowledge that you have read, understood, and agree to the above terms. If you do not agree, do not use Skillbuilder.
  ''';


  _saveLandingPage() async {
    SharedPreferences landingPagePref = await SharedPreferences.getInstance();
    landingPagePref.setBool('loadLandingPage', loadLandPage);
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Please accept the terms of service to continue"),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Close"),
                ),
              ],
            )
    ).then((value) => value ?? false);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Welcome to SkillBuilder!",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Courier New",
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.deepOrange,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 80,
              // Adjust this value as needed
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 80.0),
                // Add extra padding to the bottom
                child: Text(
                  termsAndConditions,
                  style: TextStyle(
                    fontFamily: "Courier New",
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  _saveLandingPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OpenAIScreen()),
                  );
                },
                child: const Text("Agree to Terms & Conditions"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
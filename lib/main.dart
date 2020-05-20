import 'package:flutter/material.dart';
import 'upload_card.dart';
import 'download_card.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  final accountCredentials = new ServiceAccountCredentials.fromJson(json.decode(json.encode(r'''
  {
    "type": "service_account",
    "private_key_id": "3914be2e1e800a3e6725329f92751fbe0c4e86df",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDZINj6XuycbgIB\nvW6KlQ1RGPOxkQPGOLwWDhqTbSAy7hqpuB0oMaSXoMnDdeOBIfRFeEWm7OToOIqR\nfATvUdMOKCjaKMhM0dzJHIYo1Mj/hbE+7mHVj3vFE4H+k8ULuPmpQrDpxb2WHK7u\nYDbBA1eI8wcYsFhon/GRr9V2Lwf9++d4DJxbuquUezOG8MrpSENRD42Yf6itJYH3\nXLF77cVdOm0xdem++WbZ5Ivzx/hvk6uhBIo54YFEZyz7VIhht54rL9BrrvR/jQDz\ncsJm1l6kYfYcVY5bB6jcuvijJYUjSYmR9aTuum3y96Bd314WkiRKEW+U2k8VTF48\ngzZrTSItAgMBAAECggEABy5iL+X45AqW9Z2zin7BKWQFaVE2DJEscelLSl11WI+X\nGDwfCeRjSeIbraOqjWuyvuy8hLemQ8c4Yb42JEkpjV194K/Vr869zHUkTccybn+h\nW+uVFthdIJ+KOgHw71NtK0vFMcj/uMCpCS9ZPNI0uY3aJWlbaFYod6gEpz2t5eHU\nMKbhBDUyqp6YJAnLtsLfU3/gUp/Ms9CQWJwMMjZq7sA/7543M/Ls+2pXpZ6CULG8\ncxPgdOtRNGwqvBNrlskVbuDfannPXCeG5cIOhzkI3ggTDwOfFRjB3otPQxPOPCFi\nm/Pz/qHVr6pFvgZXUPwQypydtI3vGpe6aVPtOfNFMQKBgQD0l7HPAsPa2bS7vWaa\nkwTAlf0qB1pkF9x+f5JdJSYuVQasvkweL6fW8pOVaOsHVPh/h8dW+62a4lmXk7le\nbf1M8Ukr1efbRLyb+mQ230c0vov7GRPywvI8d84Y6G1nYw20shQ2H8F7Uf7ECTY/\nVUA24uc7U8pfH8gV3fl5YCMxEQKBgQDjQT6Vl0yM2S6kDZfvcG1AQH7eoBwL6p+n\nuaFgvSxGhLHB+b2Ge1snXUdqFJYYF8/aExWUb1lc7exTliWmSRK08j3fOMNm3RfR\nQWku6eesf7XNf11rPMoYugIgYGF/tOpBQ8hq1m7tlX/kghratnFf1NiY5yVLwRBE\nlVD+ml9fXQKBgQCN+F7k4Z39MdCOCGm93wgrIORJuOrmnlMFudai6iU3T3MIYYyd\nGNw7D6JKXxPMta1nmNBD1OH3vNpz+PLntMAKISNvpkFmLIetobD5iLA0FUX7AZtq\nlW01W/Ts0DxwfjY+Y/8HS3dqtTVDZHVwXXNgaGP/M6uLe08QIj/kC8FhgQKBgQDM\n2AjTynekFjhmhCJKICs6WWiCwAvH6gtToo4Gpz57qiyYzsa5rAO0be5rfnb07LHc\nvosbK2t/yq7VgWgahY+pLxn6Vi48UFqhsrZfJVRBNzTnMUFB4p/AvhogmQAJn0fw\n4GqNcxC2c6W+klAmiYGUgkVjPiduK27Ag19owDnruQKBgGGOWgRmzsIm4BM+Tttq\n1mufQlrV0bR0Fv5I5O7+WA+zpHSZjasv9WjkVywuhN6FUcWXqrVvDDbVzhYvx3re\nciGEblniYwq+l/y/FpKAnhohV98ZDbrWELqCzWPOsuBu9/nEIQKC3BU1GHWL60dv\nsH3boY/P/QF/U3mAbHL1l5Bj\n-----END PRIVATE KEY-----\n",
    "client_email": "shdrive@quickstart-1575192151112.iam.gserviceaccount.com",
    "client_id": "107439062331262794385"
  }
  ''')));
//  await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  AuthClient client = await clientViaServiceAccount(
      accountCredentials,
      ['https://www.googleapis.com/auth/drive']);
  var drive = DriveApi(client);
  print(drive);
  runApp(new MyApp(drive: drive));
}

class MyApp extends StatefulWidget {
  final DriveApi drive;
  MyApp({
    @required this.drive,
  }): assert(drive != null);

  @override
  _MyAppState createState() => new _MyAppState(drive: drive);
}

class _MyAppState extends State<MyApp> {
  DriveApi drive;
  _MyAppState({
    @required this.drive
  });

  final _formKey = GlobalKey<FormState>();

  final key = 'M@n1@K_90854';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool valid = false;

  String inputKey;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {

      setState(() {
        inputKey = prefs.getString('key') ?? '';
        if (inputKey == key) {
          valid = true;
        }
      });
    });


  }

  @override
  Widget build(BuildContext context) {

    if (!valid)
      return MaterialApp(
      title: 'login',
      home: Scaffold(
        appBar: AppBar(
          title: Text('login'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('Enter key.'),
              TextFormField(
                autovalidate: true,
                decoration: const InputDecoration(
                  hintText: 'key',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value != key) {
                    return 'Please enter valid key';
                  }
                  return null;
                },
                onSaved: (value) {
                  inputKey = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    _prefs.then((SharedPreferences prefs) {
                      prefs.setString('key', key).then((bool) {
                        if (bool == true)
                          setState(() {
                            valid = true;
                          });
                      });
                    });
                    setState(() {
                      valid = true;
                    });
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        )
      ),
    );
    else
      return MaterialApp(
      home: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: choices.map((Choice choice) {
                return Tab(
                  text: choice.title,
                  icon: Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChoiceCard(drive: drive, choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Upload', icon: Icons.cloud_upload),
  const Choice(title: 'Download', icon: Icons.cloud_download)
];

class ChoiceCard extends StatelessWidget {
  final DriveApi drive;
  ChoiceCard({Key key, this.drive, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    if (choice.title == 'Upload')
      return UploadPage(drive: drive);

    return DownloadPage(drive: drive,);

  }
}


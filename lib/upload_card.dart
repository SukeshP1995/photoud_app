import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'multi_image_form.dart';
import 'utils.dart';
import 'constants.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class UploadPage extends StatefulWidget{
  final DriveApi drive;
  UploadPage({
    @required this.drive
  });
  @override
  _UploadPageState createState() => _UploadPageState(drive: drive);

}

class _UploadPageState extends State<UploadPage> {
  DateTime currentDate = DateTime.now();
  bool isLoading = false;
  DriveApi drive;
  _UploadPageState({
    @required this.drive,
  });
  final _formKey = GlobalKey<FormState>();
  List<Asset> images = List<Asset>();
  int sno = 0;

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(
      child: CircularProgressIndicator(),
    ) :
    Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            autovalidate: true,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              final n = num.tryParse(value);
              if(n == null || n < 1) {
                return '"$value" is not a valid number';
              }
              return null;
            },
            onSaved: (value) {
              sno = num.tryParse(value);
            },
          ),
          Text('Pick date'),
          DateTimeField(
            format: DateFormat("yyyy-MM-dd"),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
            },
            initialValue: DateTime.now(),
            onSaved: (value) {
              currentDate = value;
            },
          ),
          MultiImageFormField(
            autovalidate: true,
            initialValue: List<Asset>(),
            validator: (value) {
              if (value.length == 0) {
                return 'Please pick images';
              }
              return null;
            },
            onSaved: (value) {
              images = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {

                SnackBar snackBar;
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _formKey.currentState.reset();
                  setState(() {
                    isLoading = true;
                  });
                  String currentDateStr = DateFormat('yyyy-MM-dd').format(currentDate);
                  print(currentDateStr);
                  String folderID = '';
                  try {
                    folderID = await searchFolderID(drive, PHOTOUD, currentDateStr);
                  } on RangeError catch(_) {
                    folderID = await createFolder(drive, currentDateStr, PHOTOUD);
                  }
                  String snoID = '';
                  try {
                    snoID = await searchFolderID(drive, folderID, sno.toString());
                  } on RangeError catch(_) {
                    snoID = await createFolder(drive, sno.toString(), folderID);
                  }
                  await Future.wait(images.map((image) async => uploadAsset(drive, image, snoID).then((value) => (value))));
                  snackBar = SnackBar(
                    content: Text('Uploaded successfully!')
                  );
                  images = List<Asset>();
                  setState(() {
                    isLoading = false;
                  });
                }
                else {
                  snackBar = SnackBar(
                    content: Text('All contents not filled!')
                  );
                }
                Scaffold.of(context).showSnackBar(snackBar);
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

}

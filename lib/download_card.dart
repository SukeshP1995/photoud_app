import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'utils.dart';
import 'constants.dart';

class DownloadPage extends StatefulWidget{
  DriveApi drive;
  DownloadPage({
    @required this.drive
  });
  _DownloadPageState createState() => _DownloadPageState(drive: drive);
}

class _DownloadPageState extends State<DownloadPage> {
  DriveApi drive;
  _DownloadPageState({
    @required this.drive,
  });
  final _formKey = GlobalKey<FormState>();
  int sno = 0;
  DateTime currentDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text('Enter serial no.'),
          TextFormField(
            autovalidate: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Serial no.',
            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                SnackBar snackBar;
                if (_formKey.currentState.validate()) {
                  // todo: Process data.
                  _formKey.currentState.save();
                  String date = DateFormat('yyyy-MM-dd').format(currentDate);
                  print(date);
                  String dateID = '';
                  try {
                    dateID = await searchFolderID(drive, PHOTOUD, date);
                    String snoID = '';
                    try {
                      snoID = await searchFolderID(drive, dateID, sno.toString());
                      await downloadAllFilesInFolder(drive, snoID);
                      snackBar = SnackBar(
                        content: Text('Downloaded successfully')
                      );
                      _formKey.currentState.reset();
                    } on RangeError catch(_) {
                      snackBar = SnackBar(
                        content: Text('No records for this sno')
                      );
                    }
                  } on RangeError catch(_) {
                    snackBar = SnackBar(
                      content: Text('No records for this date')
                    );
                  }
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

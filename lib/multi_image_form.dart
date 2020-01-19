import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:async';

class MultiImageFormField extends FormField<List<Asset>> {
  List<Asset> images = List<Asset>();

  MultiImageFormField({
    FormFieldSetter<List<Asset>> onSaved,
    FormFieldValidator<List<Asset>> validator,
    List<Asset> initialValue,
    bool autovalidate = false
  }): super(
    onSaved: onSaved,
    validator: validator,
    initialValue: initialValue,
    autovalidate: autovalidate,
    builder: (FormFieldState<List<Asset>> state) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ImageButton(
            state: state,
          ),
          Flexible(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: List.generate(state.value.length, (index) {
                Asset asset = state.value[index];
                return AssetThumb(
                  asset: asset,
                  width: 300,
                  height: 300,
                );
              }),
            )
          ),
          state.hasError?
          Text(
            state.errorText,
            style: TextStyle(
                color: Colors.red
            ),
          ) :
          Container()
       ]
      );
    }
  );

}




class ImageButton<I> extends StatelessWidget {
  ImageButton({Key key,
    @required this.state,
  }) : super(key: key);

  final FormFieldState<List<Asset>> state;

  Future<void> loadAssets() async {


    List<Asset> resultList = new List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
      );
    } on Exception catch (e) {
      e.toString();
    }
    print(resultList.length);
    state.didChange(resultList);
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Pick images"),
      onPressed: () { loadAssets(); },
    );
  }
}



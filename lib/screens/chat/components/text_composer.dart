import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({this.callback});

  final Function({String text, File imgFile}) callback;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.photo_camera, color: Colors.blue),
          onPressed: pickImage,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.black12,
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(
                hintText: "Start Typing...",
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (text) =>
                  setState(() => _isComposing = text.isNotEmpty),
              onSubmitted: (_) => _resetController(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send, color: Colors.blue),
          onPressed: _isComposing ? _resetController : null,
        ),
      ],
    );
  }

  void _resetController() {
    widget.callback(text: _controller.text);
    _controller.clear();
    setState(() => _isComposing = false);
  }

  void pickImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (file == null)
      return;
    else
      widget.callback(imgFile: file);
  }
}

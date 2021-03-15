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
          icon: Icon(Icons.photo_camera),
          onPressed: () async {
            final file =
                await ImagePicker.pickImage(source: ImageSource.camera);
            if (file == null)
              return;
            else
              widget.callback(imgFile: file);
          },
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration.collapsed(hintText: "Send a message"),
            onChanged: (text) => setState(() => _isComposing = text.isNotEmpty),
            onSubmitted: (_) => _resetController(),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
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
}

import 'package:chat_flutter/screens/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Online"), elevation: 0),
      body: bottomNavigationBar(),
    );
  }

  Widget bottomNavigationBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextComposer(callback: (text) => _sendMessage(text)),
    );
  }

  void _sendMessage(String text) {
    Firestore.instance.collection('messages').add({
      text: text,
    });
  }
}

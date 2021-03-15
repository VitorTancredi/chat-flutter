import 'dart:io';

import 'package:chat_flutter/screens/components/chat_messages.dart';
import 'package:chat_flutter/screens/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged
        .listen((user) => setState(() => _currentUser = user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser.displayName}'
            : 'Chat App'),
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scafoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("você deslogou com sucesso"),
                      backgroundColor: Colors.black,
                    ));
                  })
              : Container(),
        ],
      ),
      body: Column(
        children: [
          _allMessages(),
          _textComposer(),
        ],
      ),
    );
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      return user;
    } catch (_) {
      return null;
    }
  }

  Widget _allMessages() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('messages')
            .orderBy('time')
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              List<DocumentSnapshot> documents =
                  snapshot.data.documents.reversed.toList();
              return ListView.builder(
                itemCount: documents.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return ChatMessages(
                    documents[index].data,
                    documents[index].data['userId'] == _currentUser?.uid,
                  );
                },
              );
          }
        },
      ),
    );
  }

  Widget _textComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextComposer(callback: _sendMessage),
    );
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scafoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login"),
        backgroundColor: Colors.black,
      ));
    }
    Map<String, dynamic> data = {
      "userId": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(imgFile);

      final taskSnapshot = await task.onComplete;
      final url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }

    if (text != null && text.isNotEmpty) {
      data['text'] = text;
    }

    Firestore.instance.collection('messages').add(data);
  }
}

import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _avatar(!mine),
          SizedBox(width: 8.0),
          Expanded(child: _message()),
          SizedBox(width: 8.0),
          _avatar(mine),
        ],
      ),
    );
  }

  Widget _avatar(bool isVisible) {
    return isVisible
        ? CircleAvatar(
            backgroundImage: NetworkImage(
              data['senderPhotoUrl'],
            ),
          )
        : const SizedBox();
  }

  Widget _message() {
    return Column(
      crossAxisAlignment:
          !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        _messageContent(),
        _senderName(),
      ],
    );
  }

  Widget _messageContent() {
    return data['imgUrl'] != null
        ? Container(
            decoration: BoxDecoration(color: Colors.black),
            width: 300,
            height: 200,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.network(data['imgUrl']),
            ),
          )
        : Text(
            data['text'],
            textAlign: mine ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          );
  }

  Widget _senderName() {
    return Text(
      data['senderName'],
      style: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }
}

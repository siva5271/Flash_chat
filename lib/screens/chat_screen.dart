import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

final _fireStore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool showSpinner = false;

  final _auth = FirebaseAuth.instance;
  late String messageText;
  void GetCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  void GetMessages() async {
    setState(() {
      showSpinner = false;
    });
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var messages in snapshot.docs) {
        print(messages.data());
      }
    }
    setState(() {
      showSpinner = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                GetMessages();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessageStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          messageText = value;
                        },
                        style: TextStyle(color: Colors.black),
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          await _fireStore.collection('messages').add({
                            'sender': loggedInUser.email,
                            'text': messageText,
                            'timeStamp': new DateTime.now().toString()
                          });
                          setState(() {
                            showSpinner = false;
                          });
                          messageText = '';
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender, required this.text, required this.isSender});
  late String sender;
  late String text;
  late bool isSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 10),
          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: isSender ? Radius.circular(30) : Radius.circular(0),
                topRight: isSender ? Radius.circular(0) : Radius.circular(30)),
            color: isSender ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                "$text ",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 15,
                    color: isSender ? Colors.white : Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('messages')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final messages = (snapShot.data! as QuerySnapshot).docs;
          // print(messages);
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            // print(message);
            final String messageText = message['text'].toString();
            final String messageSender = message['sender'].toString();
            final messageWidget = MessageBubble(
              sender: messageSender,
              text: messageText,
              isSender: loggedInUser.email == messageSender ? true : false,
            );
            messageWidgets.add(messageWidget);
          }
          return Expanded(
              child: ListView(
            reverse: true,
            children: messageWidgets,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ));
        });
  }
}

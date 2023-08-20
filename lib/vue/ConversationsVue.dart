import 'package:flutter/material.dart';

class ConversationsVue extends StatefulWidget {
  const ConversationsVue({super.key});

  final String title="Conversations";

  @override
  State<ConversationsVue> createState() => _ConversationsVueState();
}

class _ConversationsVueState extends State<ConversationsVue> {
  final userName_Email = TextEditingController();
  final mdp = TextEditingController();

  @override
  void dispose() {
    userName_Email.dispose();
    mdp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              Text("Conversation Vue"),
          ],
        ),
      ),
    );
  }
}
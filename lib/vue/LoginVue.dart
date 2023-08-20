import 'package:flutter/material.dart';
import 'package:discution_app/vue/ConversationsVue.dart';

class LoginVue extends StatefulWidget {
  const LoginVue({super.key});

  final String title="Login";

  @override
  State<LoginVue> createState() => _LoginVueState();
}

class _LoginVueState extends State<LoginVue> {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: userName_Email,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre username ou mail',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                obscureText: true,
                controller: mdp,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Entrée votre mdp',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Code à exécuter lorsque le bouton est pressé
                print('le username ou email est : '+userName_Email.text+" | le mdp est : "+mdp.text);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConversationsVue()),
                );
              },
              child: Text('validé'),
            ),
          ],
        ),
      ),
    );
  }
}
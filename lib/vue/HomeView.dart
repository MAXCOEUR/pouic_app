import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:flutter/material.dart';

import '../outil/Constant.dart';
import 'UserListeView.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});
  final LoginModel lm=Constant.loginModel!;

  final ConversationTest convTest=ConversationTest();
  final UserListeView userTest=UserListeView();

  final String title="Conversations";

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; // 0 pour convTest, 1 pour mesTest

  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
      Widget selectedWidget=widget.convTest;
      if (_selectedIndex == 0) {
        selectedWidget = widget.convTest;
      } else if (_selectedIndex == 1) {
        selectedWidget = widget.userTest;
      } else {

      }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // Hauteur de la nouvelle barre
        child: CustomAppBar(
          userImageBytes: widget.lm.user.Avatar
        ),
      ),
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Conversation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Utilisateur',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


class ConversationTest extends StatelessWidget{
  ConversationTest({super.key});
  LoginModel lm = Constant.loginModel!;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(lm.user.uniquePseudo),
          Image.memory(lm.user.Avatar!)
        ],
      ),
    );
  }
}

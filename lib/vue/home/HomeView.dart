import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/SocketSingleton.dart';
import 'package:discution_app/vue/home/ConversationListeView.dart';
import 'package:discution_app/vue/widget/CustomAppBar.dart';
import 'package:discution_app/vue/home/RechercheListeView.dart';
import 'package:discution_app/vue/home/amis/AmisView.dart';
import 'package:discution_app/vue/widget/CustomDrawer.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key}){
    SocketSingleton.instance.reconnect();
  }
  final LoginModel lm=Constant.loginModel!;

  final ConversationListeView convView=ConversationListeView();
  final RechercheListeView rechercheView=RechercheListeView();
  final AmisView amisView=AmisView();

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
      Widget selectedWidget=widget.convView;
      if (_selectedIndex == 0) {
        selectedWidget = widget.convView;
      } else if (_selectedIndex == 1) {
        selectedWidget = widget.amisView;
      } else if (_selectedIndex == 2) {
        selectedWidget = widget.rechercheView;
      }

    return Scaffold(
      appBar: CustomAppBar(
          arrowReturn: false,
      ),
      drawer: CustomDrawer(),
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Conversation',
          ),BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Amis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  @override
  void dispose(){
    SocketSingleton.instance.disconnect();
    super.dispose();
  }
}


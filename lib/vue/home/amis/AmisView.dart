import 'package:Pouic/Controller/HomeController.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/home/amis/AmisListeView.dart';
import 'package:Pouic/vue/home/amis/DemandeAmisListeView.dart';
import 'package:Pouic/vue/home/amis/DemandeEnvoyeAmisListeView.dart';
import 'package:flutter/material.dart';


class AmisView extends StatefulWidget {
  AmisView({super.key});
  final LoginModel lm=LoginModelProvider.getInstance((){}).loginModel!;

  final AmisListeView amisTest=AmisListeView();
  final DemandeAmisListeView demandeAmisTest=DemandeAmisListeView();
  final DemandeEnvoyeAmisListeView demandeEnvoyeAmisTest=DemandeEnvoyeAmisListeView();

  final String title="Conversations";

  @override
  State<AmisView> createState() => _AmisViewState();
}

class _AmisViewState extends State<AmisView> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    Widget selectedWidget=widget.amisTest;
    if (_selectedIndex == 0) {
      selectedWidget = widget.amisTest;
    } else if (_selectedIndex == 1) {
      selectedWidget = widget.demandeAmisTest;
    } else if (_selectedIndex == 2) {
      selectedWidget = widget.demandeEnvoyeAmisTest;
    }

    return Scaffold(
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Amis',
          ),BottomNavigationBarItem(
            icon: Icon(Icons.call_received),
            label: 'Demande d\'amis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Demande d\'amis envoyé',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Couleur des éléments sélectionnés (icônes et texte)
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }
}

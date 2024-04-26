import 'dart:io';
import 'dart:typed_data';

import 'package:Pouic/Controller/HomeController.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/outil/SocketSingleton.dart';
import 'package:Pouic/vue/home/ConversationListeView.dart';
import 'package:Pouic/vue/home/post/PostListView.dart';
import 'package:Pouic/vue/home/pouireal/pouireal_view.dart';
import 'package:Pouic/vue/widget/CustomAppBar.dart';
import 'package:Pouic/vue/home/RechercheListeView.dart';
import 'package:Pouic/vue/home/amis/AmisView.dart';
import 'package:Pouic/vue/widget/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeView extends StatefulWidget {

  HomeView({super.key}) {
    SocketSingleton.instance.reconnect();
  }

  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;



  final String title = "Conversations";

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; // 0 pour convTest, 1 pour mesTest
  late HomeController homeController;

  late final PostListview postview;
  late final PouirealView pouirealView;
  late final ConversationListeView convView ;
  late final RechercheListeView rechercheView ;
  late final AmisView amisView;

  late GlobalKey<PostListviewState> postListViewKey;

  @override
  void initState() {
    homeController = HomeController(update);
    postListViewKey = GlobalKey<PostListviewState>();
    postview = PostListview(key: postListViewKey,);
    convView = ConversationListeView();
    rechercheView = RechercheListeView();
    amisView = AmisView();
    pouirealView= PouirealView();
  }

  void update() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedIndex = index;
      if(index==0){
        postListViewKey.currentState?.up();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedWidget = postview;
    if (_selectedIndex == -1) {
      selectedWidget = Container();
    }else if (_selectedIndex == 0) {
      selectedWidget = postview;
    }else if (_selectedIndex == 1) {
      selectedWidget = pouirealView;
    }else if (_selectedIndex == 2) {
      selectedWidget = convView;
    } else if (_selectedIndex == 3) {
      selectedWidget = amisView;
    } else if (_selectedIndex == 4) {
      selectedWidget = rechercheView;
    }

    return Scaffold(
      appBar: CustomAppBar(
        arrowReturn: false,
      ),
      drawer: CustomDrawer(),
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Pouic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Pouireal',
          ),
          BottomNavigationBarItem(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message),
                if (homeController.nbrMessageNonLu != null &&
                    homeController.nbrMessageNonLu! > 0)
                  Container(
                    padding: EdgeInsets.all(SizeMarginPading.h3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      homeController.nbrMessageNonLu.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeFont.p2,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Conversation',
          ),
          BottomNavigationBarItem(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.supervised_user_circle),
                if (homeController.nbrDemande != null &&
                    homeController.nbrDemande! > 0)
                  Container(
                    padding: EdgeInsets.all(SizeMarginPading.h3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      homeController.nbrDemande.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeFont.p2,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Amis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.background, // Couleur d'arrière-plan
        selectedItemColor: Theme.of(context).colorScheme.primary, // Couleur des éléments sélectionnés (icônes et texte)
        unselectedItemColor: Theme.of(context).colorScheme.onBackground, // Couleur des éléments non sélectionnés (icônes et texte)
      ),
    );
  }

  @override
  void dispose() {
    SocketSingleton.instance.disconnect();
    homeController.dispose();
    super.dispose();
  }
}

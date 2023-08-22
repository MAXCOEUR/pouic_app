import 'package:flutter/material.dart';

import '../Controller/UserController.dart';
import '../Model/UserListeModel.dart';
import '../Model/UserModel.dart';
import '../outil/Constant.dart';
import 'UserDetailView.dart';

class UserListeView extends StatefulWidget{
  final LoginModel lm= Constant.loginModel!;
  UserListeView({super.key});

  @override
  State<UserListeView> createState() => _UserListeViewState();
}
class _UserListeViewState extends State<UserListeView> {

  UserListe users=UserListe();
  UserController? userController;

  final ScrollController _scrollController = ScrollController();
  int page=0;
  bool isLoadingMore = false;

  _UserListeViewState(){
    page=0;
    userController = UserController(users);
    userController!.addUser_inListe(page, "", reponseUpdate);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Ajoute un écouteur pour le défilement
  }

  void reponseUpdate(){
    setState(() {
      // Appeler setState pour actualiser la liste
    });
  }

  Future<void> _refreshData() async {
    page=0;
    userController!.removeAllUser_inListe();
    userController!.addUser_inListe(page, "", reponseUpdate);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !isLoadingMore) {

      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore = true; // Définir isLoadingMore à true pour indiquer le chargement
      });

      page++; // Augmenter le numéro de page pour charger la page suivante
      userController!.addUser_inListe(page, "", reponseUpdate);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void DetailUser(User user){
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UserDetailleView(user)),
    );
  }


  Widget _buildUserListTile(User user) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child:GestureDetector(
            onTap: () {
              DetailUser(user);
            },
            child:Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child: user.Avatar != null
                          ? Image.memory(
                        user.Avatar!,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.account_circle, size: 50),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Pseudo"),
                        Text(user.pseudo),
                      ]
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Pseudo Unique"),
                        Text(user.uniquePseudo),
                      ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refreshData, // Fonction à appeler lors du rafraîchissement
        child:Container(
          color: Theme.of(context).colorScheme.primary, // Changez la couleur ici
          child:Center(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: users.users.length,
              itemBuilder: (context, index) {
                final user = users.users[index];
                return _buildUserListTile(user);
              },
            ),
          ),
      ),
    );

  }
}
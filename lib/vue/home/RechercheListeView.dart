import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/widget/SearchTextField.dart';
import 'package:flutter/material.dart';

import '../../Controller/UserController.dart';
import '../../Model/UserListeModel.dart';
import '../../Model/UserModel.dart';
import '../../outil/Constant.dart';
import 'UserItemListeView.dart';
import 'UserDetailView.dart';

class RechercheListeView extends StatefulWidget{
  final LoginModel lm= LoginModelProvider.getInstance((){}).loginModel!;
  RechercheListeView({super.key});

  @override
  State<RechercheListeView> createState() => _RechercheListeViewState();
}
class _RechercheListeViewState extends State<RechercheListeView> {

  UserListe users=UserListe();
  UserController? userController;

  String rechercheInput="";

  final ScrollController _scrollController = ScrollController();
  int page=0;
  bool isLoadingMore = false;

  _RechercheListeViewState(){
    userController = UserController(users);
    recherche(rechercheInput);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Ajoute un écouteur pour le défilement
  }

  void reponseUpdate(){
    setState(() {
    });
  }
  void reponseUpdateError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }

  Future<void> _refreshData() async {
    recherche(rechercheInput);
  }

  void recherche(String recherche){
    page=0;
    userController!.removeAllUser_inListe();
    userController!.addUser_inListe(page, recherche, reponseUpdate,reponseUpdateError);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !isLoadingMore) {

      // Lorsque l'utilisateur atteint le bas de la liste
        isLoadingMore = true; // Définir isLoadingMore à true pour indiquer le chargement


      page++; // Augmenter le numéro de page pour charger la page suivante
      userController!.addUser_inListe(page, "", reponseUpdate,reponseUpdateError);

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
    return UserItemListeView(
      user: user,
      onTap: DetailUser,
      type:1
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            SearchTextField(
              onSearch: (value) {
                rechercheInput = value;
                recherche(value);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable inner ListView's scrolling
                  itemCount: users.users.length,
                  itemBuilder: (context, index) {
                    final user = users.users[index];
                    return _buildUserListTile(user);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
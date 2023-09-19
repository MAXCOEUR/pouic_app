import 'package:Pouic/Controller/UserC.dart';
import 'package:Pouic/Controller/UserController.dart';
import 'package:Pouic/Model/UserListeModel.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/home/UserItemListeView.dart';
import 'package:Pouic/vue/widget/SearchTextField.dart';
import 'package:Pouic/vue/home/UserDetailView.dart';
import 'package:flutter/material.dart';



class DemandeEnvoyeAmisListeView extends StatefulWidget{
  final LoginModel lm= LoginModelProvider.getInstance((){}).loginModel!;
  DemandeEnvoyeAmisListeView({super.key});

  @override
  State<DemandeEnvoyeAmisListeView> createState() => _DemandeEnvoyeAmisListeViewState();
}
class _DemandeEnvoyeAmisListeViewState extends State<DemandeEnvoyeAmisListeView> {
  UserC userCreate = UserC();
  UserListe users=UserListe();
  UserController? userController;

  String rechercheInput="";

  final ScrollController _scrollController = ScrollController();
  int page=0;
  bool isLoadingMore = false;

  _DemandeEnvoyeAmisListeViewState(){
    userController = UserController(users);

  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Ajoute un écouteur pour le défilement
    recherche(rechercheInput);
  }

  void reponseUpdate(){
    setState(() {
    });
  }
  void reponseError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }

  Future<void> _refreshData() async {
    recherche(rechercheInput);
  }

  void recherche(String recherche){
    page=0;
    userController!.removeAllUser_inListe();
    userController!.addSendDemande_inListe(page, recherche, reponseUpdate,reponseError);
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
      userController!.addSendDemande_inListe(page, "", reponseUpdate,reponseError);

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
        type:2,
      onTapButtonRight: deleteDemandeAmis,
    );
  }

  void deleteDemandeAmis(User user){
    userCreate.deleteDemandeAmis(user, reponseDeleteDemandeAmis,reponseError);
  }

  void reponseDeleteDemandeAmis(User u){
    setState(() {
      userController!.deleteUser(u);
    });
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
            if (users.users.length==0)
              Text("Vous n'avez envoyé aucune demande d'amis."),
            if (users.users.length>0)
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
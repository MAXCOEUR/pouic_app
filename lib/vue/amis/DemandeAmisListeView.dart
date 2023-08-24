import 'package:discution_app/Controller/UserController.dart';
import 'package:discution_app/Model/UserListeModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/ItemListeView/UserItemListeView.dart';
import 'package:discution_app/vue/SearchTextField.dart';
import 'package:discution_app/vue/UserDetailView.dart';
import 'package:flutter/material.dart';



class DemandeAmisListeView extends StatefulWidget{
  final LoginModel lm= Constant.loginModel!;
  DemandeAmisListeView({super.key});

  @override
  State<DemandeAmisListeView> createState() => _DemandeAmisListeViewState();
}
class _DemandeAmisListeViewState extends State<DemandeAmisListeView> {

  UserListe users=UserListe();
  UserController? userController;

  String rechercheInput="";

  final ScrollController _scrollController = ScrollController();
  int page=0;
  bool isLoadingMore = false;

  _DemandeAmisListeViewState(){
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
    userController!.addDemande_inListe(page, recherche, reponseUpdate,reponseUpdateError);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            SearchTextField(
              onSearch: (value) {
                rechercheInput=value;
                recherche(value);
              },
            ),
            Expanded(
              child: Center(
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
          ],
        ),
      ),
    );
  }

}
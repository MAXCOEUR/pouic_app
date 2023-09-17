import 'package:Pouic/Controller/ConversationC.dart';
import 'package:Pouic/Controller/UserController.dart';
import 'package:Pouic/Model/ConversationModel.dart';
import 'package:Pouic/Model/UserListeModel.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/home/UserItemListeView.dart';
import 'package:Pouic/vue/home/UserDetailView.dart';
import 'package:Pouic/vue/widget/CustomAppBar.dart';
import 'package:Pouic/vue/widget/SearchTextField.dart';
import 'package:flutter/material.dart';

class ConvDetailView extends StatefulWidget{
  final LoginModel lm= LoginModelProvider.getInstance((){}).loginModel!;
  Conversation conversation;
  ConvDetailView({required this.conversation,super.key});

  @override
  State<ConvDetailView> createState() => _ConvDetailViewState();
}
class _ConvDetailViewState extends State<ConvDetailView> {

  UserListe users=UserListe();
  UserController? userController;
  ConversationC conversationC = ConversationC();

  final ScrollController _scrollController = ScrollController();
  int page=0;
  bool isLoadingMore = false;

  _ConvDetailViewState(){
    userController = UserController(users);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Ajoute un écouteur pour le défilement
    recherche();
  }

  void reponseUpdate(){
    if (mounted) {
      setState(() {
        // Votre code de mise à jour de l'état ici
      });
    }
  }
  void reponseError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }

  Future<void> _refreshData() async {
    recherche();
  }

  void recherche(){
    page=0;
    userController!.removeAllUser_inListe();
    userController!.addUserConv_inListe(widget.conversation,page, "", reponseUpdate,reponseError);
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
      userController!.addUserConv_inListe(widget.conversation,page, "", reponseUpdate,reponseError);

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
  void RemoveUserConv(User user){
    conversationC.deleteUser(user,widget.conversation, reponseDeleteUser,reponseError);
  }

  void reponseDeleteUser(User u){
    setState(() {
      userController!.deleteUser(u);
    });
  }


  Widget _buildUserListTile(User user) {
    if (user.uniquePseudo == widget.conversation.uniquePseudo_admin) {
      return Row(
        children: [
          Expanded(
            child: UserItemListeView(
              user: user,
              onTap: DetailUser,
              type: 0,
              onTapButtonRight: RemoveUserConv,
            ),
          ),
          Icon(Icons.admin_panel_settings), // L'icône de l'administrateur
        ],
      );
    } else {
      return UserItemListeView(
        user: user,
        onTap: DetailUser,
        type: 0,
        onTapButtonRight: RemoveUserConv,
      );
    }
  }

  Widget ConvDetail(){
    return Row(
      children: [
        InkWell(
          onTap: () {
            Scaffold.of(context).openDrawer(); // Ouvre le Drawer
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Constant.buildImageConversation(widget.conversation,125,true,context),
            ),
          ),
        ),
        Text(widget.conversation.name),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(arrowReturn: true),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(SizeMarginPading.h1),
                padding: EdgeInsets.all(SizeMarginPading.h3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(SizeBorder.radius)
                ),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: Constant.buildImageConversation(
                            widget.conversation, 125, true, context),
                      ),
                    ),
                    Expanded(
                        child: Center(
                            child: Text(widget.conversation.name,
                                style: TextStyle(fontSize: SizeFont.h3)))),
                  ],
                ),
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(SizeMarginPading.h3),
                child: Text("Liste des participants"),
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = users.users[index];
                    return _buildUserListTile(user);
              },
              childCount: users.users.length,
            ),
          ),
        ],
      ),
    );
  }
}
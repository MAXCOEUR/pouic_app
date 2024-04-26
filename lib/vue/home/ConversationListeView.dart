import 'package:Pouic/Controller/ConversationsController.dart';
import 'package:Pouic/Model/ConversationListeModel.dart';
import 'package:Pouic/Model/ConversationModel.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/outil/SocketSingleton.dart';
import 'package:Pouic/vue/CreateConversationVue.dart';
import 'package:Pouic/vue/home/ConversationItemListeView.dart';
import 'package:Pouic/vue/home/message/MessagerieView.dart';
import 'package:Pouic/vue/widget/SearchTextField.dart';
import 'package:flutter/material.dart';

import '../../Controller/UserController.dart';
import '../../Model/UserListeModel.dart';
import '../../Model/UserModel.dart';
import '../../outil/Constant.dart';
import '../widget/LoadingDialog.dart';
import 'UserItemListeView.dart';
import 'UserDetailView.dart';

class ConversationListeView extends StatefulWidget {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;

  ConversationListeView({super.key});

  @override
  State<ConversationListeView> createState() => _ConversationListeViewState();
}

class _ConversationListeViewState extends State<ConversationListeView> {
  ConversationListe conversations = ConversationListe();
  ConversationController? conversationController;

  String rechercheInput = "";

  final ScrollController _scrollController = ScrollController();
  int page = 0;
  bool isLoadingMore = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    conversationController =
        ConversationController(conversations, reponseUpdate);
    recherche(rechercheInput);
    _scrollController
        .addListener(_onScroll); // Ajoute un écouteur pour le défilement
  }

  void reponseUpdate() {
    if (mounted) {
      setState(() {
        _isLoading=false;
      });
    }
  }

  void reponseUpdateError(Exception ex) {
    setState(() {
      _isLoading=false;
    });
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  Future<void> _refreshData() async {
    recherche(rechercheInput);
  }

  void recherche(String recherche) {
    page = 0;
    conversationController!.removeAllConversation_inListe();
    conversationController!.addConversation_inListe(
        page, recherche, reponseUpdate, reponseUpdateError);
    setState(() {
      _isLoading=true;
    });
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !isLoadingMore) {
      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore =
            true; // Définir isLoadingMore à true pour indiquer le chargement
      });

      page++; // Augmenter le numéro de page pour charger la page suivante
      conversationController!
          .addConversation_inListe(page, "", reponseUpdate, reponseUpdateError);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void OpenConversation(Conversation conversation) async {
    conversationController?.setIdConvertationOpen(conversation.id);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MessagerieView(conv: conversation)),
    );
    conversationController?.setNullIdConvertationOpen();
    _refreshData();
    SocketSingleton.instance.socket.emit("updateMessageNonLu",{'token':widget.lm.token});
  }

  Widget _buildConversationListTile(Conversation conversation) {
    return ConversationItemListeView(
      conversation: conversation,
      onTap: OpenConversation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:(_isLoading)?LoadingDialog(): RefreshIndicator(
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
              if (conversations.conversations.length==0)
                Expanded(child:
                Text("Vous n'êtes dans aucune conversation."),
                ),
              if (conversations.conversations.length>0)
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // Disable inner ListView's scrolling
                    itemCount: conversations.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations.conversations[index];
                      return _buildConversationListTile(conversation);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Conversation conv = Conversation(0, "", "",null, 0);
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateConversationVue(
                      conversation: conv,
                      created: true,
                    )),
          );
          // Appeler _refreshData ici pour actualiser les données
          _refreshData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

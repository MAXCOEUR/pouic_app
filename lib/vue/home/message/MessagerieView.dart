import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Controller/MessagesController.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/MessageListeModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/CreateConversationVue.dart';
import 'package:discution_app/vue/ItemListeView/MessageItemListeView.dart';
import 'package:discution_app/vue/home/message/AddAmisConvView.dart';
import 'package:discution_app/vue/home/message/RemoveUserConvView.dart';
import 'package:flutter/material.dart';

class MessagerieView extends StatefulWidget {
  MessagerieView({super.key, required this.conv});

  Conversation conv;
  final LoginModel lm = Constant.loginModel!;
  ConversationC conversationC = ConversationC();

  @override
  State<MessagerieView> createState() => _MessagerieViewState();
}

class _MessagerieViewState extends State<MessagerieView> {
  TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  int lastTailleListe=0;

  MessageListe messageListe = MessageListe();
  late MessagesController messagesController;

  @override
  void initState() {
    super.initState();
    messagesController = MessagesController(messageListe,widget.conv,reponseUpdate);

    messagesController.initListe(widget.conv.id,reponseInit,reponseError);

    _scrollController.addListener(_onScroll);
  }
  @override
  void dispose() {
    messagesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void modifierConv() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateConversationVue(
                conversation: widget.conv,
                created: false,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
  }

  void addUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddAmisConvView(
                conversation: widget.conv,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
  }

  void removeUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RemoveUserConvView(
                conversation: widget.conv,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !isLoadingMore) {

      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore = true; // Définir isLoadingMore à true pour indiquer le chargement
      });
      int LastId = messagesController.getLastId();
      messagesController.addOldMessage_inListe(widget.conv.id,LastId,reponseUpdate,reponseError);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  PreferredSizeWidget customAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: widget.conv.image != null
                  ? Image.memory(
                      widget.conv.image!,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.comment),
            ),
          ),
          Expanded(
            child: Center(child: Text(widget.conv.name)),
          ),
          if (widget.conv.uniquePseudo_admin == widget.lm.user.uniquePseudo)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'modifierC') {
                  modifierConv();
                } else if (value == 'supprimerC') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Supprimer la conversation'),
                        content: Text(
                            'Êtes-vous sûr de vouloir supprimer cette conversation ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Fermer la boîte de dialogue
                            },
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.conversationC.deleteConv(
                                  widget.conv,
                                  reponseDeleteConversation,
                                  reponseError);
                              Navigator.pop(context);
                              //fermer la conversation ici
                            },
                            child: Text('Supprimer'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'ajouterU') {
                  addUser();
                } else if (value == 'supprimerU') {
                  removeUser();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'modifierC',
                  child: Text('Modifier conversation'),
                ),
                const PopupMenuItem<String>(
                  value: 'supprimerC',
                  child: Text('Supprimer conversation'),
                ),
                const PopupMenuItem<String>(
                  value: 'ajouterU',
                  child: Text('ajouter utilisateur'),
                ),
                const PopupMenuItem<String>(
                  value: 'supprimerU',
                  child: Text('supprimer utilisateur'),
                ),
              ],
            ),
        ],
      ),
    );
  }
  Widget SendMessageBar(){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: 'Votre message'),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              String messageText = _messageController.text;
              if (messageText.isNotEmpty) {
                // Envoyer le message via le socket
                messagesController.sendMessageToSocket(messageText);
                _messageController.clear(); // Effacer le champ après l'envoi
              }
            },
            child: Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messageListe.messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = messageListe.messages[index];
                Widget listItem = _buildMessageListTile(message);
                return listItem;
              },
            ),
          ),
          SendMessageBar(),
        ],
      ),
    );
  }


  Widget _buildMessageListTile(MessageModel message) {
    return MessageItemListeView(
      message: message,
    );
  }

  reponseDeleteConversation() {
    print("la conversation a été supprimé");
    Navigator.pop(context);
  }

  reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  reponseUpdate(){
    if (mounted) {
      setState(() {
        // Votre code de mise à jour de l'état ici
      });
    }
  }
  reponseInit(){
    if(messageListe.messages.length>0 && !messageListe.messages[messageListe.messages.length-1].isread && messageListe.messages.length>lastTailleListe){
      messagesController.addOldMessage_inListe(widget.conv.id,messageListe.messages[messageListe.messages.length-1].id,reponseInit,reponseError);
      lastTailleListe=messageListe.messages.length;
    }
    else{
      int index = messagesController.firstMessageNotOpen();
      //_scrollController.jumpTo(40.0*index); //marche pas il faut que arrive a trouve la taille des wirget dans la listeView
      messagesController.luAllMessage(widget.conv.id);
    }
    reponseUpdate();
  }
}

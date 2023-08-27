import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/CreateConversationVue.dart';
import 'package:discution_app/vue/home/message/AddAmisConvView.dart';
import 'package:discution_app/vue/home/message/RemoveUserConvView.dart';
import 'package:discution_app/vue/widget/CustomAppBar.dart';
import 'package:discution_app/vue/widget/SearchTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MessagerieView extends StatefulWidget{
  MessagerieView({super.key,required this.conv});

  Conversation conv;
  final LoginModel lm=Constant.loginModel!;
  ConversationC conversationC = ConversationC();

  @override
  State<MessagerieView> createState() => _MessagerieViewState();
}
class _MessagerieViewState extends State<MessagerieView> {

  void modifierConv()async{
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateConversationVue(conversation: widget.conv,created: false,)),
      );
      // Appeler _refreshData ici pour actualiser les données
      setState(() {

      });
  }
  void addUser()async{
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAmisConvView(conversation: widget.conv,)),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {

    });
  }
  void removeUser()async{
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RemoveUserConvView(conversation: widget.conv,)),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {

    });
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
                        content: Text('Êtes-vous sûr de vouloir supprimer cette conversation ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Fermer la boîte de dialogue
                            },
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.conversationC.deleteConv(widget.conv, reponseDeleteConversation,reponseDeleteConversationError);
                              Navigator.pop(context);
                              //fermer la conversation ici
                            },
                            child: Text('Supprimer'),
                          ),
                        ],
                      );
                    },
                  );
                }else if (value == 'ajouterU') {
                  addUser();
                }else if (value == 'supprimerU') {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Center(child: Text("messagirie : "+widget.conv.name),),

    );
  }


  reponseDeleteConversation(){
    print("la conversation a été supprimé");
    Navigator.pop(context);
  }
  reponseDeleteConversationError(Exception ex){
    Constant.showAlertDialog(context,"Erreur","erreur lors de la requette a l'api : "+ex.toString());
  }

}
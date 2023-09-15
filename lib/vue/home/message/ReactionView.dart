import 'package:discution_app/Model/ReactionModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReactionView extends StatelessWidget {
  List<Reaction> reactions;
  ReactionView(this.reactions,this.callBackDelete);
  Function callBackDelete;
  LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;

  @override
  Widget build(BuildContext context) {
    // Créez un dictionnaire pour regrouper les réactions par emoji
    final Map<String, List<Reaction>> groupedReactions = {};

    // Remplissez le dictionnaire en regroupant les réactions par emoji
    reactions.forEach((reaction) {
      if (!groupedReactions.containsKey(reaction.reaction)) {
        groupedReactions[reaction.reaction] = [];
      }
      groupedReactions[reaction.reaction]!.add(reaction);
    });

    return GestureDetector(
      onTap: ()=>_showUserReactionsDialog(context),
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground.withAlpha(75),
        borderRadius: BorderRadius.circular(SizeBorder.radius),
      ),
      child: Wrap(
        children: groupedReactions.entries.map((entry) {
          final emoji = entry.key;
          final userList = entry.value;

          // Limitez le nombre d'affichages à 3
          final limitedUserList = userList.take(3).toList();
          final overflowCount = userList.length - limitedUserList.length;

          return Container(
            padding: EdgeInsets.only(top: 2.0, bottom: 2, right: 4, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 20),
                ),
                for (final user in limitedUserList)
                  Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child: Constant.buildAvatarUser(user.user, 10, false,context),
                    ),
                  ),
                if (overflowCount > 0)
                  Text(
                    '+$overflowCount',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    ),);
  }

  void _showUserReactionsDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Définissez les pourcentages de largeur et de hauteur souhaités
    final double dialogWidthPercentage = 0.8; // 80%

    final double dialogWidth = screenWidth * dialogWidthPercentage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Réactions par utilisateur"),
              SizedBox(height: 10),
              Container(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    children: reactions.map((reaction) {
                      return Container(
                        margin: EdgeInsets.all(SizeMarginPading.h3),
                        padding: EdgeInsets.all(SizeMarginPading.h3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(SizeBorder.radius)
                        ),
                        
                        child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: ClipOval(
                              child: Constant.buildAvatarUser(reaction.user, 30, false,context),
                            ),
                          ),
                          Text("@" + reaction.user.uniquePseudo),
                          Text(reaction.user.pseudo),
                          Row(children: [
                            Text(reaction.reaction),
                            if (loginModel.user==reaction.user)
                              GestureDetector(
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: (){
                                    callBackDelete();
                                    Navigator.of(context).pop();
                                    },
                                ),
                              )
                          ],
                          ),


                        ],
                      ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer"),
            ),
          ],
        );
      },
    );
  }




}
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:flutter/material.dart';

class ConversationItemListeView extends StatelessWidget {
  final Conversation conversation;
  final LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;
  Function onTap;

  ConversationItemListeView({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.all(SizeMarginPading.p1),
        child:GestureDetector(
          onTap: () {
            onTap(conversation);
          },
          child:Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child:Padding(
              padding: EdgeInsets.all(SizeMarginPading.p1),
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
                      child: Constant.buildImageOrIcon(
                          Constant.baseUrlAvatarConversation+"/"+conversation.id.toString(),
                          Icon(Icons.comment,size: 50,),true
                      ),
                    ),
                  ),
                  SizedBox(width: SizeMarginPading.h3),
                  Expanded(
                      child: Center( child: Text(conversation.name,style: TextStyle(fontSize: SizeFont.h3)))
                  ),
                  if (conversation.unRead > 0)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(SizeMarginPading.h2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          conversation.unRead.toString(),
                          style: TextStyle(color: Colors.white,fontSize: SizeFont.p1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
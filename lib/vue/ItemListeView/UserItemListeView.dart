import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/material.dart';

import '../../Model/UserModel.dart';

class UserItemListeView extends StatelessWidget {
  final User user;
  Function onTap;
  int type;
  Function? onTapButtonRight;
  LoginModel lm = Constant.loginModel!;

  UserItemListeView(
      {super.key,
      required this.user,
      required this.onTap,
      required this.type,
      this.onTapButtonRight});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.all(SizeMarginPading.p1),
        child: GestureDetector(
          onTap: () {
            if(user!=lm.user)
            onTap(user);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(SizeBorder.radius),
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeMarginPading.p1),
              child: Row(
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
                          Constant.baseUrlAvatarUser+"/"+user.uniquePseudo+".png",
                          Icon(Icons.account_circle)
                      ),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Pseudo",style: TextStyle(fontSize: SizeFont.p1)),
                        Text(user.pseudo,style: TextStyle(fontSize: SizeFont.p1)),
                      ]),
                  Text("@"+user.uniquePseudo,style: TextStyle(fontSize: SizeFont.p1)),
                  if (type == 1)
                    Icon((user.sont_amis == true)
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank),
                  if (type == 2)
                    if(user!=lm.user)
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        onTapButtonRight!(user);
                      },
                    ),
                  if (type == 3)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            onTapButtonRight!(user, true);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            onTapButtonRight!(user, false);
                          },
                        ),
                      ],
                    ),
                  if (type == 4)
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        onTapButtonRight!(user,Conversation(0, "name", "uniquePseudo_admin", 0));
                      },
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

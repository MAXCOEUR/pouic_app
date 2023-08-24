import 'package:flutter/material.dart';

import '../../Model/UserModel.dart';

class UserItemListeView extends StatelessWidget {
  final User user;
  Function onTap;

  UserItemListeView({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child:GestureDetector(
          onTap: () {
            onTap(user);
          },
          child:Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                      child: user.Avatar != null
                          ? Image.memory(
                        user.Avatar!,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.account_circle, size: 50),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Pseudo"),
                        Text(user.pseudo),
                      ]
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Pseudo Unique"),
                        Text(user.uniquePseudo),
                      ]
                  ),
                  Icon((user.sont_amis==true)?Icons.check_box_outlined:Icons.check_box_outline_blank)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
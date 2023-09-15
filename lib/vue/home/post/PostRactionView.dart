import 'package:discution_app/Controller/PostController.dart';
import 'package:discution_app/Model/PostModel.dart';
import 'package:discution_app/Model/ReactionModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/home/UserDetailView.dart';
import 'package:discution_app/vue/widget/CustomAppBar.dart';
import 'package:flutter/material.dart';

class PostRactionView extends StatefulWidget {
  final PostModel post;
  final PostController postsController;

  PostRactionView({required this.post,required this.postsController});

  @override
  _PostRactionViewState createState() => _PostRactionViewState();
}

class _PostRactionViewState extends State<PostRactionView> {

  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  int page=0;

  @override
  void initState() {
    super.initState();
    widget.postsController.addReactionPost(page,widget.post, reponseUpdate, reponseError);
    _scrollController.addListener(_onScroll);
  }
  reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  reponseUpdate() {
    print(widget.post);
    if (mounted) {
      setState(() {});
    }
  }
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore =
        true; // Définir isLoadingMore à true pour indiquer le chargement
      });
      page++;
      widget.postsController.addReactionPost(
          page,
          widget.post,
          reponseUpdate,
          reponseError);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Widget reactionLigne(Reaction reaction){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDetailleView(reaction.user)),
        );
      },
      child: Container(
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
          ],
          ),


        ],
      ),
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(arrowReturn: true),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.post.reactions.length,
        itemBuilder: (BuildContext context, int index) {
          Reaction reaction = widget.post.reactions[index];
          return ListTile(
            title: reactionLigne(reaction),
          );
        },
      ),
    );
  }


}
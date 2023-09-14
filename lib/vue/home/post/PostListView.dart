import 'package:discution_app/Controller/PostController.dart';
import 'package:discution_app/Model/PostListeModel.dart';
import 'package:discution_app/Model/PostModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/ItemListeView/PostItemListeView.dart';
import 'package:flutter/material.dart';

class PostListview extends StatefulWidget {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;

  final String title = "Conversations";

  @override
  State<PostListview> createState() => _PostListviewState();
}

class _PostListviewState extends State<PostListview> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  late PostController postsController;
  PostListe postListe = PostListe();

  @override
  void initState() {
    super.initState();
    postsController = PostController(postListe, reponseUpdate);

    postsController.initListe(reponseUpdate, reponseError);
    _scrollController.addListener(_onScroll);
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

      postsController!.addOldMessage_inListe(postListe.posts[0].id,reponseUpdate, reponseError);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshData() async {
    print("_refreshData");
  }

  Widget _buildConversationListTile(PostModel post) {
    return Container(
        child: PostItemListeView(post: post,DeleteCallBack: onDeleteItem),
      margin: EdgeInsets.all(SizeMarginPading.h3),
    );
  }

  void onDeleteItem(PostModel post){
    if(mounted){
      setState(() {
        postsController.deletePost(post);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // Disable inner ListView's scrolling
                itemCount: postListe.posts.length,
                itemBuilder: (context, index) {
                  PostModel post = postListe.posts[index];
                  return _buildConversationListTile(post);
                },
              ),
            ),

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //
        },
        child: Icon(Icons.add),
      ),
    );
  }

  reponseUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }
  @override
  void dispose() {
    postsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

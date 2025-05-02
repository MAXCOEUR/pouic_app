import 'package:pouic/Controller/PostController.dart';
import 'package:pouic/Model/PostListeModel.dart';
import 'package:pouic/Model/PostModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/vue/home/post/PostItemListeView.dart';
import 'package:pouic/vue/home/post/CreatePost.dart';
import 'package:flutter/material.dart';

import '../../widget/LoadingDialog.dart';

class PostListview extends StatefulWidget {
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;

  PostListview({super.key});

  final String title = "Conversations";

  @override
  State<PostListview> createState() => PostListviewState();
}

class PostListviewState extends State<PostListview> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  late PostController postsController;
  PostListe postListe = PostListe();

  bool _isLoading = false;



  void up() {
    _scrollController.jumpTo(0);
    refreshData();
  }
  Future<void> refreshData() async {
    setState(() {
      _isLoading=true;
    });
    postsController.initListeGeneralPost(reponseUpdate, reponseError);
  }

  @override
  void initState() {
    super.initState();
    postsController = PostController(postListe, reponseUpdate);
    refreshData();
    _scrollController.addListener(_onScroll);
  }
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore) {
      // Lorsque l'utilisateur atteint le bas de la liste
      setState(() {
        isLoadingMore =
        true; // Définir isLoadingMore à true pour indiquer le chargement
      });

      postsController.addGeneralPost_inListe(postListe.posts[postListe.posts.length-1].id,reponseScroll, reponseError);
    }
  }
  void reponseScroll(){
    setState(() {
      isLoadingMore = false;
    });
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
      body:(_isLoading)?LoadingDialog(): RefreshIndicator(
        onRefresh: refreshData,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  // Disable inner ListView's scrolling
                  itemCount: postListe.posts.length,
                  itemBuilder: (context, index) {
                    PostModel post = postListe.posts[index];
                    return _buildConversationListTile(post);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePost(null)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  reponseUpdate() {
    if (mounted) {
      setState(() {
        _isLoading=false;
      });
    }
  }

  reponseError(Exception ex) {
    setState(() {
      _isLoading=false;
    });
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

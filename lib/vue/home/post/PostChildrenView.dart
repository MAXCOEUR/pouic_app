import 'package:pouic/Controller/PostController.dart';
import 'package:pouic/Model/PostListeModel.dart';
import 'package:pouic/Model/PostModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/vue/home/post/CreatePost.dart';
import 'package:pouic/vue/home/post/PostItemListeView.dart';
import 'package:pouic/vue/home/post/PostRactionView.dart';
import 'package:pouic/vue/widget/CustomAppBar.dart';
import 'package:flutter/material.dart';

class PostChildrenView extends StatefulWidget {
  final PostModel post;

  PostChildrenView({required this.post});

  @override
  _PostChildrenViewState createState() => _PostChildrenViewState();
}

class _PostChildrenViewState extends State<PostChildrenView> {

  late PostController postsController;
  PostListe postListe = PostListe();

  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    postsController = PostController(postListe, reponseUpdate);
    postsController.initListeChildPost(widget.post, reponseUpdate, reponseError);
    postsController.fillParent(widget.post);
    _scrollController.addListener(_onScroll);
  }
  void reponseScroll(){
    setState(() {
      isLoadingMore = false;
    });
  }
  reponseError(Exception ex) {
    Constant.showAlertDialog(context, "Erreur",
        "erreur lors de la requette a l'api : " + ex.toString());
  }

  reponseUpdate() {
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

      postsController.addChildPost_inListe(
          postListe.posts[postListe.posts.length - 1].id,
          widget.post,
          reponseScroll,
          reponseError);
    }
  }

  void onDeleteItem(PostModel post){
    Navigator.pop(context);
  }

  Widget sendBar(){
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreatePost(widget.post)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeMarginPading.h1,right: SizeMarginPading.h1,left: SizeMarginPading.h1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(SizeBorder.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Cliquez ici pour rédiger une réponse...",
                  style: TextStyle(
                    color: Colors.grey, // Couleur de texte de suggestion
                  ),
                ),
              ),
              Icon(Icons.add),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(arrowReturn: true),
        body: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    margin: EdgeInsets.all(SizeMarginPading.h3),
                    child: PostItemListeView(DeleteCallBack: onDeleteItem, post: widget.post),
                  )
                ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    child: IconButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PostRactionView(post: widget.post,postsController: postsController)),
                          );
                        },
                        icon: Icon(Icons.insert_chart_outlined)
                    ),
                  )

                ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  sendBar(),
                ]),
              ),
              if (postListe.posts.length==0)
                SliverList(
                  delegate: SliverChildListDelegate([
                    Text("Le post n'a reçu aucune réponse."),
                  ]),
                ),
              if (postListe.posts.length>0)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    PostModel post = postListe.posts[index];
                    return Container(
                      child: PostItemListeView(
                          post: post, DeleteCallBack: onDeleteItem),
                      margin: EdgeInsets.all(SizeMarginPading.h3),
                    );
                  },
                  childCount: postListe.posts.length,
                ),
              ),
            ]
        ),
    );
  }

}
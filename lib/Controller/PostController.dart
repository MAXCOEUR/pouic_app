
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/PostListeModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/PostModel.dart';
import 'package:discution_app/Model/ReactionModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/outil/SocketSingleton.dart';
import 'package:socket_io_client/src/socket.dart';

class PostController {
  PostListe posts;
  LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;
  Function callBack;

  PostController(this.posts,this.callBack) {
  }
  void dispose() {
  }

  void deletePost(PostModel post){
    posts.remove(post);
  }


  List<FileModel> splitGroupConcat(String? linkfile,String? name){
    List<FileModel> listeFile= [];
    List<String> listeLinkFile= [];
    List<String> listenameFile= [];
    if(linkfile!=null && name!=null){
      listeLinkFile=linkfile.split(',');
      listenameFile=name.split(',');
    }else{
      listeLinkFile=[];
      listenameFile=[];
    }
    for(int i=0;i<listeLinkFile.length;i++){
      listeFile.add(FileModel(listeLinkFile[i], listenameFile[i]));
    }

    return listeFile;
  }
  void addOldMessage_inListe(int id_lastMessage,Function callBack,Function callBackError){
    print("getPost Api");
    String AuthorizationToken='Bearer '+lm.token;
    Api.instance.getData(
        "post", {'id_lastMessage': id_lastMessage}, {'Authorization': AuthorizationToken})
        .then(
            (response) async {



          List<dynamic> jsonData = response.data;

          List<PostModel> postsTmp=[];


          for(Map<String, dynamic> data in jsonData){

            PostModel? parent;
            if(data["id_parent"]!=null){
              parent = await getPostOne(data["id_parent"]);
            }

            List<FileModel> listeFile=splitGroupConcat(data["linkfile"],data["name"]);
            User user= User(data['email'], data['uniquePseudo'], data['pseudo'],data["bio"],data["extension"]);
            PostModel post = PostModel(data["id"], user, data["Message"], DateTime.parse(data["date"]),listeFile,data["nbr_reaction"],data["nbr_reponse"],(data["a_deja_reagi"]==1)?true:false,parent);
            if(data["reaction"]!=null){
              Reaction reaction = Reaction(User(data['reaction_email'], data['reaction_uniquePseudo'], data['reaction_pseudo'],data["reaction_bio"],data["reaction_extension"]), data["reaction"]);
              post.addReaction(reaction);
            }

            postsTmp.add(post);
          }
          posts.addOldMessages(postsTmp);

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }

  void initListe(Function callBack,Function callBackError){
    addOldMessage_inListe(0,callBack,callBackError);
  }
  static void sendReaction(PostModel message,String reaction,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.postData("reaction", {"id_message":message.id,"emoji":reaction}, null, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        callBack(Reaction(message.user, reaction));
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }
  static void deleteReaction(PostModel message,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.deleteData("reaction", {"id_message":message.id}, null, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        callBack();
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }
  static void delete(PostModel message,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.deleteData("post", null, {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        callBack(message);
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }
  static void edit(PostModel message,String edit,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.putData("post", {'message':edit}, {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        message.message=response.data["message"];
        callBack(message);
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }

  Future<PostModel?> getPostOne(int id_Post) async {
    String AuthorizationToken = 'Bearer ${lm.token}';
    try {
      final response = await Api.instance.getData("post/one", {'id_message': id_Post}, {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        Map<String, dynamic> jsonData = response.data;

        // Crée le PostModel actuel
        List<FileModel> listeFileParent = splitGroupConcat(jsonData["linkfile"], jsonData["name"]);
        User user = User(jsonData["email"], jsonData["uniquePseudo"], jsonData["pseudo"], jsonData["bio"], jsonData["extension"]);
        PostModel currentPost = PostModel(jsonData["id"], user, jsonData["Message"], DateTime.parse(jsonData["date"]), listeFileParent, jsonData["nbr_reaction"],jsonData["nbr_reponse"],(jsonData["a_deja_reagi"]==1)?true:false,null);

        // Vérifie si le parent existe
        if (jsonData["id_parent"] != null) {
          // Appelle récursivement la fonction pour obtenir le parent
          PostModel? parentPost = await getPostOne(jsonData["id_parent"]);

          // Si le parentPost n'est pas null, assigne-le au currentPost
          if (parentPost != null) {
            currentPost.parent = parentPost;
          }
        }

        return currentPost;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }



}

import 'package:dio/dio.dart';
import 'package:Pouic/Model/FileCustom.dart';
import 'package:Pouic/Model/FileModel.dart';
import 'package:Pouic/Model/PostListeModel.dart';
import 'package:Pouic/Model/MessageModel.dart';
import 'package:Pouic/Model/PostModel.dart';
import 'package:Pouic/Model/ReactionModel.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Api.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/outil/SocketSingleton.dart';
import 'package:socket_io_client/src/socket.dart';

class PostController {
  PostListe posts;
  LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  Function callBack;

  PostController(this.posts, this.callBack) {}

  void dispose() {}

  void deletePost(PostModel post) {
    posts.remove(post);
  }

  List<FileModel> splitGroupConcat(String? linkfile, String? name) {
    List<FileModel> listeFile = [];
    List<String> listeLinkFile = [];
    List<String> listenameFile = [];
    if (linkfile != null && name != null) {
      listeLinkFile = linkfile.split(',');
      listenameFile = name.split(',');
    } else {
      listeLinkFile = [];
      listenameFile = [];
    }
    for (int i = 0; i < listeLinkFile.length; i++) {
      listeFile.add(FileModel(listeLinkFile[i], listenameFile[i]));
    }

    return listeFile;
  }

  void addGeneralPost_inListe(int id_lastMessage, Function callBack, Function callBackError) {
    print("addGeneralPost_inListe");
    String AuthorizationToken = 'Bearer ' + lm.token;
    Api.instance.getData("post", {'id_lastMessage': id_lastMessage},
        {'Authorization': AuthorizationToken}).then((response) async {
      List<dynamic> jsonData = response.data;

      List<PostModel> postsTmp = [];

      for (Map<String, dynamic> data in jsonData) {
        PostModel? parent;
        if (data["id_parent"] != null) {
          parent = await getPostOne(data["id_parent"]);
        }

        List<FileModel> listeFile =
            splitGroupConcat(data["linkfile"], data["name"]);
        User user = User(email:data['email'], uniquePseudo:data['uniquePseudo'], pseudo:data['pseudo'],bio:data["bio"], extension:data["extension"]);
        PostModel post = PostModel(
            data["id"],
            user,
            data["Message"],
            DateTime.parse(data["date"]),
            listeFile,
            data["nbr_reaction"],
            data["nbr_reponse"],
            (data["a_deja_reagi"] == 1) ? true : false,
            parent);

        postsTmp.add(post);
      }
      if(id_lastMessage==0){
        posts.removeAll();
      }
      posts.addOldMessages(postsTmp);

      callBack();
    }, onError: (error) {
      callBackError(error);
    });
  }

  void initListeGeneralPost(Function callBack, Function callBackError) {
    addGeneralPost_inListe(0, callBack, callBackError);
  }
  void addUserPost_inListe(int id_lastMessage,User user, Function callBack, Function callBackError) {
    print("getPost Api");
    String AuthorizationToken = 'Bearer ' + lm.token;
    Api.instance.getData("post/users", {'pseudoUnique':user.uniquePseudo,'id_lastMessage': id_lastMessage},
        {'Authorization': AuthorizationToken}).then((response) async {
      List<dynamic> jsonData = response.data;

      List<PostModel> postsTmp = [];

      for (Map<String, dynamic> data in jsonData) {
        PostModel? parent;
        if (data["id_parent"] != null) {
          parent = await getPostOne(data["id_parent"]);
        }

        List<FileModel> listeFile =
        splitGroupConcat(data["linkfile"], data["name"]);
        User user = User(email:data['email'], uniquePseudo:data['uniquePseudo'], pseudo:data['pseudo'],bio:data["bio"], extension:data["extension"]);
        PostModel post = PostModel(
            data["id"],
            user,
            data["Message"],
            DateTime.parse(data["date"]),
            listeFile,
            data["nbr_reaction"],
            data["nbr_reponse"],
            (data["a_deja_reagi"] == 1) ? true : false,
            parent);

        postsTmp.add(post);
      }
      if(id_lastMessage==0){
        posts.removeAll();
      }
      posts.addOldMessages(postsTmp);

      callBack();
    }, onError: (error) {
      callBackError(error);
    });
  }
  void initListeUserPost(User u,Function callBack, Function callBackError) {
    addUserPost_inListe(0,u, callBack, callBackError);
  }
  void addChildPost_inListe(int id_lastMessage,PostModel post, Function callBack, Function callBackError) {
    print("getPost Api");
    String AuthorizationToken = 'Bearer ' + lm.token;
    Api.instance.getData("post/childs", {'id_post':post.id,'id_lastMessage': id_lastMessage},
        {'Authorization': AuthorizationToken}).then((response) async {
      List<dynamic> jsonData = response.data;

      List<PostModel> postsTmp = [];

      for (Map<String, dynamic> data in jsonData) {
        PostModel? parent;
        //car ou veu pas que ca affiche le parent qui est la page

        List<FileModel> listeFile =
        splitGroupConcat(data["linkfile"], data["name"]);
        User user = User(email:data['email'], uniquePseudo:data['uniquePseudo'], pseudo:data['pseudo'],bio:data["bio"], extension:data["extension"]);
        PostModel post = PostModel(
            data["id"],
            user,
            data["Message"],
            DateTime.parse(data["date"]),
            listeFile,
            data["nbr_reaction"],
            data["nbr_reponse"],
            (data["a_deja_reagi"] == 1) ? true : false,
            parent);

        postsTmp.add(post);
      }
      posts.addOldMessages(postsTmp);

      callBack();
    }, onError: (error) {
      callBackError(error);
    });
  }
  void initListeChildPost(PostModel p,Function callBack, Function callBackError) {
    addChildPost_inListe(0,p, callBack, callBackError);
  }
  void addReactionPost(int page,PostModel post, Function callBack, Function callBackError) {
    print("getPost Api");
    String AuthorizationToken = 'Bearer ' + lm.token;
    Api.instance.getData("reaction", {'message_id':post.id,'page': page},
        {'Authorization': AuthorizationToken}).then((response) async {
      List<dynamic> jsonData = response.data;


      for (Map<String, dynamic> data in jsonData) {

        User user = User(email:data['email'], uniquePseudo:data['uniquePseudo'], pseudo:data['pseudo'],bio:data["bio"], extension:data["extension"]);
        Reaction reaction = Reaction(
            user,
            data["emoji"]);

        post.addReaction(reaction);
      }

      callBack();
    }, onError: (error) {
      callBackError(error);
    });
  }

  static void sendReaction(PostModel message, String reaction,
      Function callBack, Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance(() {}).loginModel!;
    String AuthorizationToken = 'Bearer ${loginModel.token}';
    try {
      final response = await Api.instance.postData(
          "reaction",
          {"id_message": message.id, "emoji": reaction},
          null,
          {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        callBack(Reaction(loginModel.user, reaction));
      } else {
        throw Exception();
      }
    } catch (error) {
      callBackError(error);
    }
  }

  static void deleteReaction(
      PostModel message, Function callBack, Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance(() {}).loginModel!;
    String AuthorizationToken = 'Bearer ${loginModel.token}';
    try {
      final response = await Api.instance.deleteData(
          "reaction",
          {"id_message": message.id},
          null,
          {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        callBack();
      } else {
        throw Exception();
      }
    } catch (error) {
      callBackError(error);
    }
  }

  static void delete(
      PostModel message, Function callBack, Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance(() {}).loginModel!;
    String AuthorizationToken = 'Bearer ${loginModel.token}';
    try {
      final response = await Api.instance.deleteData("post", null,
          {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        callBack(message);
      } else {
        throw Exception();
      }
    } catch (error) {
      callBackError(error);
    }
  }

  static void edit(PostModel message, String edit, Function callBack,
      Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance(() {}).loginModel!;
    String AuthorizationToken = 'Bearer ${loginModel.token}';
    try {
      final response = await Api.instance.putData("post", {'message': edit},
          {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        message.message = response.data["message"];
        callBack(message);
      } else {
        throw Exception();
      }
    } catch (error) {
      callBackError(error);
    }
  }

  Future<PostModel?> getPostOne(int id_Post) async {
    String AuthorizationToken = 'Bearer ${lm.token}';
    try {
      final response = await Api.instance.getData("post/one",
          {'id_message': id_Post,"pseudoUnique":lm.user.uniquePseudo}, {'Authorization': AuthorizationToken});
      if (response.statusCode == 201) {
        Map<String, dynamic> jsonData = response.data;

        // Crée le PostModel actuel
        List<FileModel> listeFileParent =
            splitGroupConcat(jsonData["linkfile"], jsonData["name"]);
        User user = User(email:jsonData['email'], uniquePseudo:jsonData['uniquePseudo'], pseudo:jsonData['pseudo'],bio:jsonData["bio"], extension:jsonData["extension"]);
        PostModel currentPost = PostModel(
            jsonData["id"],
            user,
            jsonData["Message"],
            DateTime.parse(jsonData["date"]),
            listeFileParent,
            jsonData["nbr_reaction"],
            jsonData["nbr_reponse"],
            (jsonData["a_deja_reagi"] == 1) ? true : false,
            null);

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

  void fillParent(PostModel pm) async {
    PostModel? post =await getPostOne(pm.id);
    pm.parent = post?.parent;
    callBack();
  }

  static Future<void> sendPost(String messageText, List<FileCustom> listeFile, PostModel? parent) async {
    LoginModel loginModel = LoginModelProvider.getInstance(() {}).loginModel!;
    String AuthorizationToken = 'Bearer ' + loginModel.token;
    final responseCreate = await Api.instance.postData(
      'post',
      {
        'message': messageText,
        'id_parent': (parent != null) ? parent.id : null
      },
      null,
      {'Authorization': AuthorizationToken},
    );
    if (responseCreate.statusCode == 201) {
      Map<String, dynamic> jsonData = responseCreate.data;
      int idPost = jsonData["id"];
      await sendFile(idPost, listeFile);
    } else {
      return;
    }
  }

  static Future<void> sendFile(int idPost, List<FileCustom> listeFile) async {
    for (FileCustom f in listeFile) {
      try {
        final response = await Api.instance.postDataMultipart(
          'post/upload',
          {
            'file': MultipartFile.fromBytes(f.fileBytes!.toList(),
                filename: f.fileName),
            'id_message': idPost,
            'name': f.fileName
          },
          null,
          null,
        );

        if (response.statusCode == 200) {
          //callBack();
        } else {
          throw Exception();
        }
      } catch (error) {}
    }
  }
}

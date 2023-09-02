import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:discution_app/Controller/ConversationC.dart';
import 'package:discution_app/Controller/MessagesController.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageListeModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/vue/CreateConversationVue.dart';
import 'package:discution_app/vue/ItemListeView/MessageItemListeView.dart';
import 'package:discution_app/vue/home/message/AddAmisConvView.dart';
import 'package:discution_app/vue/home/message/RemoveUserConvView.dart';
import 'package:discution_app/vue/widget/parent.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

class MessagerieView extends StatefulWidget {
  MessagerieView({super.key, required this.conv});

  Conversation conv;
  final LoginModel lm = LoginModelProvider.getInstance(() {}).loginModel!;
  ConversationC conversationC = ConversationC();

  @override
  State<MessagerieView> createState() => _MessagerieViewState();
}

class _MessagerieViewState extends State<MessagerieView> {
  MessageParentModel? parent;
  TextEditingController _messageController = TextEditingController();
  List<String> listeFile = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  int lastTailleListe = 0;

  MessageListe messageListe = MessageListe();
  late MessagesController messagesController;

  bool isRecording = false;
  String? filePath;

  void setParent(MessageParentModel p) {
    setState(() {
      parent = p;
    });
  }
  void nullParent() {
    setState(() {
      parent = null;
    });
  }

  @override
  void initState() {
    super.initState();
    messagesController =
        MessagesController(messageListe, widget.conv, reponseUpdate);

    messagesController.initListe(widget.conv.id, reponseInit, reponseError);

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    messagesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (filePath == null) {
        final appDir = await getTemporaryDirectory();
        filePath = '${appDir.path}/recording.mp3';
      }
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        if (!isRecording) {
          await RecordMp3.instance.start(filePath!, (type) {});
          setState(() {
            isRecording = true;
          });
        }
      }
    }
  }

  void _stopRecording(LongPressEndDetails lped) async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        if (isRecording) {
          await RecordMp3.instance.stop();
          listeFile.clear();
          setState(() {
            isRecording = false;
            if (filePath != null) {
              File file = File(filePath!);
              if (file.existsSync()) {
                listeFile.add(filePath!);
              }
            }
          });
        }
      }
    }
  }

  void modifierConv() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateConversationVue(
                conversation: widget.conv,
                created: false,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
  }

  void addUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddAmisConvView(
                conversation: widget.conv,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
  }

  void removeUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RemoveUserConvView(
                conversation: widget.conv,
              )),
    );
    // Appeler _refreshData ici pour actualiser les données
    setState(() {});
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
      int LastId = messagesController.getLastId();
      messagesController.addOldMessage_inListe(
          widget.conv.id, LastId, reponseUpdate, reponseError);

      // Après avoir chargé les données, définissez isLoadingMore à false
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  PreferredSizeWidget customAppBar() {
    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Constant.buildImageOrIcon(
                  Constant.baseUrlAvatarConversation +
                      "/" +
                      widget.conv.id.toString(),
                  Icon(Icons.comment),
                  true),
            ),
          ),
          SizedBox(width: SizeMarginPading.h3),
          Expanded(
            child: Center(child: Text(widget.conv.name)),
          ),
          SizedBox(width: SizeMarginPading.h3),
          if (widget.conv.uniquePseudo_admin == widget.lm.user.uniquePseudo)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'modifierC') {
                  modifierConv();
                } else if (value == 'supprimerC') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Supprimer la conversation'),
                        content: Text(
                            'Êtes-vous sûr de vouloir supprimer cette conversation ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Fermer la boîte de dialogue
                            },
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.conversationC.deleteConv(widget.conv,
                                  reponseDeleteConversation, reponseError);
                              Navigator.pop(context);
                              //fermer la conversation ici
                            },
                            child: Text('Supprimer'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'ajouterU') {
                  addUser();
                } else if (value == 'supprimerU') {
                  removeUser();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'modifierC',
                  child: Text('Modifier conversation'),
                ),
                const PopupMenuItem<String>(
                  value: 'supprimerC',
                  child: Text('Supprimer conversation'),
                ),
                const PopupMenuItem<String>(
                  value: 'ajouterU',
                  child: Text('ajouter utilisateur'),
                ),
                const PopupMenuItem<String>(
                  value: 'supprimerU',
                  child: Text('supprimer utilisateur'),
                ),
              ],
            ),
          if (widget.conv.uniquePseudo_admin != widget.lm.user.uniquePseudo)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'quitter') {
                  widget.conversationC.deleteUserMe(widget.lm.user, widget.conv,
                      reponseDeleteUser, reponseError);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'quitter',
                  child: Text('Quitter la conversation'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void reponseDeleteUser(User u) {
    setState(() {
      Navigator.pop(context, true);
    });
  }

  Widget file(int index) {
    String fileName = listeFile[index];
    bool isImage = fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.gif');

    return Container(
      margin: EdgeInsets.all(SizeMarginPading.p1),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeBorder.radius),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Stack(children: [
        Positioned(
            // will be positioned in the top right of the container
            top: 0,
            right: 0,
            height: 20,
            width: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error, // border color
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    listeFile.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            )),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                child: isImage
                    ? Image.file(
                        File(fileName),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.insert_drive_file,
                        size: 50,
                      ),
              ),
              SizedBox(height: SizeMarginPading.p1),
              Text(
                path.basename(fileName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ]),
    );
  }

  void sendMessage() {
    String messageText = _messageController.text;
    messagesController.sendMessageToSocket(messageText, listeFile, parent);
    setState(() {
      listeFile.clear();
      _messageController.clear();
      nullParent();
    });
  }

  Widget SendMessageBar() {
    return Container(
      margin: EdgeInsets.all(SizeMarginPading.h1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(SizeBorder.radius),
      ),
      child: Column(
        children: [
          if (listeFile.isNotEmpty)
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // Définir l'orientation horizontale
                itemCount: listeFile.length,
                itemBuilder: (context, index) {
                  return file(index);
                },
              ),
            ),
          if (listeFile.isNotEmpty) SizedBox(height: SizeMarginPading.h3),
          if (parent!=null) Dismissible(
            key: Key(parent!.id.toString()),
            child: Parent(parent),
            onDismissed: (DismissDirection direction){
              nullParent();
            },
          ),
          Container(
            margin: EdgeInsets.all(SizeMarginPading.h1),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Appeler une fonction pour ajouter des fichiers à la liste listeFile
                    pickAndAddFilesToList();
                  },
                ),
                SizedBox(width: SizeMarginPading.h3),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message',
                    ),
                    onSubmitted: (String messageText) {
                      sendMessage();
                    },
                    textInputAction: TextInputAction.done,
                    minLines: 1,
                    maxLines: 10,
                  ),
                ),
                SizedBox(width: SizeMarginPading.h3),
                GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressEnd: _stopRecording,
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(SizeMarginPading.h3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(SizeBorder.radius)),
                      child: Text((isRecording) ? 'Enregistrement' : 'Envoyer',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background)),
                    )),
              ],
            ),
          )

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child:Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messageListe.messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final ValueKey key = ValueKey(messageListe.messages[index].id);
                final message = messageListe.messages[index];
                Widget listItem = _buildMessageListTile(message, key);
                return listItem;
              },
            ),
          ),
          SendMessageBar(),
        ],
      ),
      ),
    );
  }

  Future<void> pickAndAddFilesToList() async {
    FilePickerResult? pickedFiles =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles.files) {
        setState(() {
          if (pickedFile.path != null) {
            if (pickedFile.extension != null) {
              if (pickedFile.name.length > 255) {
                Constant.showAlertDialog(context, "Erreur",
                    "le ficher ${pickedFile.path} a un nom de plus de 255 caractere");
              } else if (pickedFile.extension == ".mp4" ||
                  pickedFile.extension == ".avi") {
                if (pickedFile.size < 75000000) {
                  listeFile.add(pickedFile.path!);
                } else {
                  Constant.showAlertDialog(context, "Erreur",
                      "la video ${pickedFile.path} fait plus de 75Mo");
                }
              } else if (pickedFile.extension == ".mp3" ||
                  pickedFile.extension == ".aac") {
                if (pickedFile.size < 20000000) {
                  listeFile.add(pickedFile.path!);
                } else {
                  Constant.showAlertDialog(context, "Erreur",
                      "le audio ${pickedFile.path} fait plus de 20Mo");
                }
              } else {
                if (pickedFile.size < 10000000) {
                  listeFile.add(pickedFile.path!);
                } else {
                  Constant.showAlertDialog(context, "Erreur",
                      "le fichier ${pickedFile.path} fait plus de 10Mo");
                }
              }
            }
          }
        });
      }
    }
  }

  Widget _buildMessageListTile(MessageModel message, ValueKey key) {
    return ListTile(
      key: key,
      title: MessageItemListeView(
        message: message,
        context: context,
        key: key,
        setParent: setParent,
      ),
    );
  }

  reponseDeleteConversation() {
    print("la conversation a été supprimé");
    Navigator.pop(context);
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

  reponseInit() {
    if (messageListe.messages.length > 0 &&
        !messageListe.messages[messageListe.messages.length - 1].isread &&
        messageListe.messages.length > lastTailleListe) {
      messagesController.addOldMessage_inListe(
          widget.conv.id,
          messageListe.messages[messageListe.messages.length - 1].id,
          reponseInit,
          reponseError);
      lastTailleListe = messageListe.messages.length;
    } else {
      int index = messagesController.firstMessageNotOpen();
      //_scrollController.jumpTo(40.0*index); //marche pas il faut que arrive a trouve la taille des wirget dans la listeView
      messagesController.luAllMessage(widget.conv.id);
    }
    reponseUpdate();
  }
}

import 'package:Pouic/vue/home/pouireal/DisplayItemPouireal.dart';
import 'package:Pouic/vue/home/pouireal/pouireal_viewmodel.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Model/pouireal_model.dart';
import 'TakePhotoPouireal.dart';

class PouirealView extends StatefulWidget {
  @override
  State<PouirealView> createState() => PouirealViewState();
}

class PouirealViewState extends State<PouirealView> {
  PouirealViewModel pouirealViewModel = PouirealViewModel();
  List<PouirealModel> _pouicreals = [];

  bool isPosted = true;

  void _recupPouicreal(){
    int lastid =0;
    if(_pouicreals.length>0){
      lastid=_pouicreals[_pouicreals.length-1].id;
    }
    Stream<List<PouirealModel>> stream = pouirealViewModel.getPouireal(lastid);
    stream.listen((pouirealModelTmp) {
      setState(() {
        _pouicreals.addAll(pouirealModelTmp);
      });
    }, onError: (error) {
      print("Erreur : $error");
    });
  }
  void _recupisPosted(){
    Stream<bool> stream = pouirealViewModel.isPosted();
    stream.listen((isPostedRecup) {
      isPosted = isPostedRecup;
    }, onError: (error) {
      print("Erreur : $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _recupisPosted();
    _recupPouicreal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetPouireal(){
    setState(() {
      _pouicreals.clear();
    });
    _recupisPosted();
    _recupPouicreal();
  }

  void onDelete(PouirealModel poui){
    Stream<int> stream = pouirealViewModel.deletePouireal(poui.id);
    stream.listen((isPostedRecup) {
      resetPouireal();
    }, onError: (error) {
      print("Erreur : $error");
    });

  }

  Widget createCardPouireal(BuildContext context, int index) {
    return DisplayItemPouirealView(pouirealModel: _pouicreals[index], onDelete: onDelete,);
  }

  Future<void> onRefresh() async {
    resetPouireal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:RefreshIndicator(
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if(notification is ScrollEndNotification && notification.metrics.extentAfter==0){
                _recupPouicreal();
              }
              return false;
            },
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      createCardPouireal,
                      childCount: _pouicreals.length,
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      
      floatingActionButton: Visibility(
        visible: !isPosted, // Afficher le bouton uniquement si isPosted est false
        child: FloatingActionButton(
          onPressed: () async {
            WidgetsFlutterBinding.ensureInitialized();

            final cameras = await availableCameras();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakePicturePouireal(cameras: cameras,callback: resetPouireal ),
              ),
            );
          },
          child: Icon(Icons.camera_alt),
          elevation: 4.0, // Élévation du bouton
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
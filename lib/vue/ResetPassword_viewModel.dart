import 'dart:async';

import 'package:pouic/repository/user_repositoty.dart';

class ResetpasswordViewmodel{

  UserRepositoty userRepository = UserRepositoty();

  void _restPasswordAssync(StreamController<bool> streamController,String emailOrUniquePsodo)async{
    bool good = await userRepository.resetPassWord(emailOrUniquePsodo);
    streamController.add(good);

  }
  Stream<bool> restPassword(String emailOrUniquePsodo){
    StreamController<bool> streamController = StreamController<bool>();

    _restPasswordAssync(streamController,emailOrUniquePsodo);

    return streamController.stream;
  }
}
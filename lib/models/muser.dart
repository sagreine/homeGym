import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:flutter/material.dart';

class Muser extends ChangeNotifier {
  FirebaseUser firebaseUser;
  // TODO: this is not tested
  fauth.User fAuthUser = fauth.FirebaseAuth.instance.currentUser;

  Muser({
    this.firebaseUser,
  });

  Future<bool> logout() async {
    final result = await FirebaseAuthUi.instance().logout();
    this.firebaseUser = null;
    this.fAuthUser = null;
    return result;
  }

  //@override
  List<Object> get props => [firebaseUser, fAuthUser];
}

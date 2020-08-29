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

  //@override
  List<Object> get props => [firebaseUser, fAuthUser];
}

import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:flutter/material.dart';

class Muser extends ChangeNotifier {
  FirebaseUser firebaseUser;

  Muser({
    this.firebaseUser,
  });

  //@override
  List<Object> get props => [firebaseUser];
}

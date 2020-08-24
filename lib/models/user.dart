import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  FirebaseUser firebaseUser;

  User({
    this.firebaseUser,
  });

  //@override
  List<Object> get props => [firebaseUser];
}

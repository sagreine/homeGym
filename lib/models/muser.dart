import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:flutter/material.dart';

class Muser extends ChangeNotifier {
  FirebaseUser _firebaseUser;
  fauth.User fAuthUser = fauth.FirebaseAuth.instance.currentUser;
  bool isNewUser;

  Muser({
    //this.firebaseUser,
    isNewUser = true,
  });

  Future<bool> logout() async {
    final result = await FirebaseAuthUi.instance().logout();
    //this.firebaseUser = null;
    isNewUser = true;

    this.fAuthUser = null;
    return result;
  }

  Future<void> delete() async {
    //final result = await FirebaseAuthUi.instance().logout();
    await fAuthUser.delete();
    //this.firebaseUser = null;
    isNewUser = true;

    this.fAuthUser = null;
  }

  String getDisplayName() {
    String displayName = fauth.FirebaseAuth.instance.currentUser.displayName;

    //user.firebaseUser.user.getDisplayName();
    if (displayName != null && displayName != "") {
      return displayName;
    }

    for (fauth.UserInfo userInfo
        in fauth.FirebaseAuth.instance.currentUser.providerData) {
      if (userInfo.displayName != null && userInfo.displayName != "") {
        return userInfo.displayName;
      }
    }

    return "Home Gym TV";
  }

  // careful, URL vs Uri
  String getPhotoURL() {
    String getPhotoURL = fauth.FirebaseAuth.instance.currentUser.photoURL;

    //user.firebaseUser.user.getDisplayName();
    if (getPhotoURL != null && getPhotoURL != "") {
      return getPhotoURL;
    }

    for (fauth.UserInfo userInfo
        in fauth.FirebaseAuth.instance.currentUser.providerData) {
      if (userInfo.photoURL != null && userInfo.photoURL != "") {
        return userInfo.photoURL;
      }
    }
    return null;
  }

  //@override
  List<Object> get props => [fAuthUser];
}

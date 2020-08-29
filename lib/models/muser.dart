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

    return "Unnamed User";
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
  List<Object> get props => [firebaseUser, fAuthUser];
}

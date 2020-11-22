import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ProfileController {
  deleteAtPath({String user}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'recursiveDelete',
        options: HttpsCallableOptions(timeout: Duration(seconds: 9)));

    var data = Map<String, String>();
    data["path"] = "USERDATA/$user";

    await callable.call(data);
  }

  deleteStorage({String user}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'storageDelete',
        options: HttpsCallableOptions(timeout: Duration(seconds: 9)));

    var data = Map<String, String>();
    data["userId"] = "$user";

    await callable.call(data);
  }

  deleteUser({BuildContext context}) async {
    print("pressed for deletion!");
    var user = Provider.of<Muser>(context, listen: false);

    await deleteAtPath(user: user.fAuthUser.uid);
    await deleteStorage(user: user.fAuthUser.uid);
    if (!await user.delete()) {
      return false;
    }
    /* cough don't copy and paste code... */
    var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    exerciseDay.lift = null;
    print("successfully logged out");
    return true;
    // pop until we get to the login page

/*
        await callable.call(data).catchError((object) {
      AuthCredential credential =
          EmailAuthProvider.credential(email: null, password: null);

      Muser().fAuthUser.reauthenticateWithCredential(credential);

      deleteStorage(user: user);
      return true;
    });
    return true;
  }*/
  }
}

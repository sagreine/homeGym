import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

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
}

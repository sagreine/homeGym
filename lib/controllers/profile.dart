import 'package:cloud_functions/cloud_functions.dart';

class ProfileController {
  deleteAtPath({String user}) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'recursiveDelete',
        options: HttpsCallableOptions(timeout: Duration(seconds: 9)));

    var data = Map<String, String>();
    data["path"] = "USERDATA/$user";

    await callable.call(data);
  }
}

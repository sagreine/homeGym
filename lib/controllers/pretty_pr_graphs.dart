import 'package:flutter/cupertino.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class PrettyPrGraphsController {
  Future<dynamic> getAllPrs(
      BuildContext context, String selectedLift, bool _isRepNotWeight) async {
    var prsModel = Provider.of<Prs>(context, listen: false);
    //var user = Provider.of<Muser>(context, listen: false);
    // what about if the mdodel exists and there's nothing in it? or handle that elsewhere e.g. UI <-- do that
    if (prsModel == null || prsModel.allPrs == null) {
      // get from the cloud
      /*prsModel.allPrs = await getAllPRsCloud(
          context: context,
          userId: user.fAuthUser.uid,
          lift: selectedLift,
          isRep: _isRepNotWeight);*/
      await PrsController().getAllPRs(context);
    }
    //else {
    return prsModel.allPrs;
    //}
  }
}

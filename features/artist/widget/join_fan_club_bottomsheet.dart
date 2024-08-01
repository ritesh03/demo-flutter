import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/subscription.artist.model.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import '../../../components/widgets/bottomsheet/joinfanclubbottomsheet/join_fan_club_plan_bottomsheet.dart';
import '../profile/artist.model.dart';

class JoinFanClubBottomSheet extends StatefulWidget {
  String? artistName;
  Result<List<SubscriptionArtistPlanModel>> subscriptionPlans;
  ArtistModel artistModel;
  bool isFromUpgrade;
  //=
  static Future<bool?> show(BuildContext context,
      {required String artistName,
      required Result<List<SubscriptionArtistPlanModel>> subscriptionPlans,
      required ArtistModel artistModel,
      required bool isFromUpgrade}) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => JoinFanClubBottomSheet(
        artistName: artistName,
        subscriptionPlans: subscriptionPlans,
        artistModel: artistModel,
        isFromUpgrade: isFromUpgrade,
      ),
    );
  }

  JoinFanClubBottomSheet(
      {Key? key,
      this.artistName,
      required this.subscriptionPlans,
      required,
      required this.artistModel,
      required this.isFromUpgrade})
      : super(key: key);

  @override
  State<JoinFanClubBottomSheet> createState() => _JoinFanClubBottomSheetState();
}

class _JoinFanClubBottomSheetState extends State<JoinFanClubBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return JoinFanClubPlanBottomSheet(
      artistName: widget.artistName,
      subscriptionPlans: widget.subscriptionPlans,
      artistModel: widget.artistModel,
      isFromUpgrade: widget.isFromUpgrade,
    );
  }
}

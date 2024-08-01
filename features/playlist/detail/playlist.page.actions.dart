import 'package:kwotdata/models/models.dart';

abstract class PlaylistPageActionCallback {
  void onUserTap(User user);

  void onBackTap();

  void onDownloadTap();

  void onFollowUserTap(User user);

  void onLikeTap();

  void onManageCollaboratorsButtonTap();

  void onOptionsTap();

  void onReloadTap();

  void onTracksFilterButtonTap();

  void onAddTracksTap();

  void onSeeAllTracksTap();
}

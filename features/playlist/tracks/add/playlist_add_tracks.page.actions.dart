import 'package:kwotdata/models/models.dart';

abstract class PlaylistAddTracksPageActionCallback {
  void onBackTap();

  void onDoneTap();

  void onAddTrackTap(Track track);

  void onRemoveTrackTap(Track track);
}

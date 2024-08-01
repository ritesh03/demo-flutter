import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class UINotification {
  late final InAppNotification inAppNotification;
  late final String title;
  late final String subtitle;
  late final User? user;

  UINotification(
    this.inAppNotification, {
    required TextLocaleResource localeResource,
  }) {
    inAppNotification.data.when(
      newFollower: (user) {
        title = localeResource.notificationNewFollowerTitle;
        subtitle = localeResource.notificationNewFollowerSubtitle(user.name);
        this.user = user;
      },
      information: (title, subtitle) {
        this.title = title;
        this.subtitle = subtitle;
        user = null;
      },
      playlistLiked: (user, _, playlistName) {
        title = localeResource.notificationPlaylistLikedTitle(user.name);
        subtitle = playlistName;
        this.user = user;
      },
      playlistCollaboratorAdded: (owner, _, playlistName, canEditItems) {
        title = canEditItems
            ? localeResource
                .notificationPlaylistCollaboratorAddedTitle(owner.name)
            : localeResource.notificationPlaylistViewerAddedTitle(owner.name);
        subtitle = playlistName;
        user = owner;
      },
    );
  }

  bool get read => inAppNotification.read;

  DateTime get date => inAppNotification.date;
}

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/collaborators/invite/playlist_collaboration_invitation.args.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.args.dart';
import 'package:kwotmusic/features/playlist/createedit/create_edit_playlist.model.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.args.dart';
import 'package:kwotmusic/features/playlist/visibility/playlist_visibility_tile.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_compact_preview.widget.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_enforcement.dart';
import 'package:kwotmusic/features/profile/subscriptions/widget/subscription_requirement_indicator.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/error_code_messages.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import 'playlist_options.model.dart';

class PlaylistOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required PlaylistOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) => ChangeNotifierProvider(
          create: (_) => PlaylistOptionsModel(args: args),
          child: const PlaylistOptionsBottomSheet()),
    );
  }

  const PlaylistOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<PlaylistOptionsBottomSheet> createState() =>
      _PlaylistOptionsBottomSheetState();
}

class _PlaylistOptionsBottomSheetState
    extends State<PlaylistOptionsBottomSheet> {
  //=
  PlaylistOptionsModel get _playlistOptionsModel =>
      context.read<PlaylistOptionsModel>();

  PlaylistActionsModel get _playlistActionsModel =>
      locator<PlaylistActionsModel>();

  @override
  Widget build(BuildContext context) {
    final margin = EdgeInsets.only(top: ComponentInset.small.h);
    final localization = LocaleResources.of(context);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          const _PlaylistBottomSheetHeader(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          const _PlaylistVisibilityOption(),
          // TODO: Like All Songs
          _PlaylistLikeOption(
            margin: margin,
            onTap: _onLikeButtonTapped,
            likeText: localization.like,
            unlikeText: localization.unlike,
          ),
          _AddTracksToPlaylistOption(
            margin: margin,
            onTap: _onAddTracksButtonTapped,
            text: localization.playlistAddSongs,
          ),
          _InviteOption(
            margin: margin,
            onTap: _onInviteButtonTapped,
            text: localization.inviteFriends,
          ),
          _ManageCollaboratorsOption(
            margin: margin,
            onTap: _onManageCollaboratorsButtonTapped,
            text: localization.manageCollaborators,
          ),
          _EditPlaylistOption(
            margin: margin,
            onTap: _onEditButtonTapped,
            text: localization.edit,
          ),
          BottomSheetTile(
              iconPath: Assets.iconQueue,
              margin: margin,
              text: localization.addToQueue,
              onTap: _onAddToQueueButtonTapped),
          // _DownloadPlaylistOption(
          //   margin: margin,
          //   onTap: _onDownloadButtonTapped,
          //   text: localization.download,
          // ),
          _SharePlaylistOption(
            margin: margin,
            onTap: _onShareButtonTapped,
            text: localization.share,
          ),
          _ReportPlaylistOption(
            margin: margin,
            onTap: _onReportButtonTapped,
            text: localization.report,
          ),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  void _onLikeButtonTapped() async {
    final playlist = _playlistOptionsModel.playlist;

    showBlockingProgressDialog(context);
    final result = await _playlistActionsModel.toggleLike(playlist);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onAddTracksButtonTapped() {
    RootNavigation.popUntilRoot(context);

    DashboardNavigation.pushNamed(
      context,
      Routes.playlistAddTracks,
      arguments: PlaylistAddTracksArgs(
        playlist: _playlistOptionsModel.playlist,
        isOnPlaylistPage: _playlistOptionsModel.isOnPlaylistPage,
      ),
    );
  }

  void _onInviteButtonTapped() {

    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "share-playlists-with-friends", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowToInviteFriends,
    );
    if (!fulfilled) return;
 RootNavigation.popUntilRoot(context);
    DashboardNavigation.pushNamed(
      context,
      Routes.playlistCollaborationInvitation,
      arguments: PlaylistCollaborationInvitationArgs(
          playlistId: _playlistOptionsModel.playlist.id),
    );
  }

  void _onManageCollaboratorsButtonTapped() {


    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "share-playlists-with-friends", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowManageCollaboration,
    );
    if (!fulfilled) return;
 RootNavigation.popUntilRoot(context);
    DashboardNavigation.pushNamed(
      context,
      Routes.managePlaylistCollaborators,
      arguments: ManagePlaylistCollaboratorsArgs(
          playlistId: _playlistOptionsModel.playlist.id),
    );
  }

  void _onEditButtonTapped() {
    RootNavigation.popUntilRoot(context);

    DashboardNavigation.pushNamed(
      context,
      Routes.createOrEditPlaylist,
      arguments: EditPlaylistArgs(
        playlist: _playlistOptionsModel.playlist,
        isOnPlaylistPage: _playlistOptionsModel.isOnPlaylistPage,
      ),
    );
  }

  void _onAddToQueueButtonTapped() async {
    final playlist = _playlistOptionsModel.playlist;

    showBlockingProgressDialog(context);
    final result =
        await locator<AudioPlaybackActionsModel>().addPlaylistToQueue(playlist);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result.isSuccess()) {
      RootNavigation.popUntilRoot(context);

      showDefaultNotificationBar(
        NotificationBarInfo.success(
          message: result.message,
          actionText: LocaleResources.of(context).viewPlayingQueue,
          actionCallback: (context) => PlayingQueueBottomSheet.show(context),
        ),
      );
    } else if (result.errorCode() != null) {
      final errorMessage =
          getErrorMessageFromErrorCode(context, result.errorCode()!);
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: errorMessage));
    } else {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onDownloadButtonTapped() {}

  void _onShareButtonTapped() async {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "share-playlists-with-friends", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowSharePlaylist,
    );
    if (!fulfilled) return;
    final playlist = _playlistOptionsModel.playlist;
    Share.share(playlist.shareableLink);
  }

  void _onReportButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final playlist = _playlistOptionsModel.playlist;
    final args =
        ReportContentArgs(content: ReportableContent.fromPlaylist(playlist));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}

class _PlaylistBottomSheetHeader extends StatelessWidget {
  const _PlaylistBottomSheetHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, Playlist>(
      selector: (_, model) => model.playlist,
      builder: (_, playlist, __) => PlaylistCompactPreview(playlist: playlist),
    );
  }
}

class _PlaylistVisibilityOption extends StatelessWidget {
  const _PlaylistVisibilityOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, Tuple2<bool, Playlist>>(
        selector: (_, model) =>
            Tuple2(model.canShowVisibilityOption, model.playlist),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          if (!canShow) return const SizedBox.shrink();

          final playlist = tuple.item2;
          return PlaylistVisibilityTile(
            margin: EdgeInsets.symmetric(vertical: ComponentInset.small.r),
            playlist: playlist,
          );
        });
  }
}

class _PlaylistLikeOption extends StatelessWidget {
  const _PlaylistLikeOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.likeText,
    required this.unlikeText,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String likeText;
  final String unlikeText;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, Tuple2<bool, bool>>(
        selector: (_, model) => Tuple2(model.canShowLikeOption, model.liked),
        builder: (_, tuple, __) {
          final canShow = tuple.item1;
          if (!canShow) return const SizedBox.shrink();

          final liked = tuple.item2;
          return BottomSheetTile(
              iconPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              margin: margin,
              text: liked ? unlikeText : likeText,
              onTap: onTap);
        });
  }
}

class _AddTracksToPlaylistOption extends StatelessWidget {
  const _AddTracksToPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, bool>(
        selector: (_, model) => model.canShowAddSongsOption,
        builder: (_, canShow, __) {
          if (!canShow) return const SizedBox.shrink();
          return BottomSheetTile(
              iconPath: Assets.iconAddMedium,
              margin: margin,
              text: text,
              onTap: onTap);
        });
  }
}

class _InviteOption extends StatelessWidget {
  const _InviteOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, bool>(
        selector: (_, model) => model.canShowInviteOption,
        builder: (_, canShow, __) {
          if (!canShow) return const SizedBox.shrink();
          return BottomSheetTile(
            iconPath: Assets.iconFriends,
            margin: margin,
            onTap: onTap,
            text: text,
            // trailing: SubscriptionRequirementIndicator(
            //   feature: SubscriptionFeature.playlistCollaboration,
            //   size: ComponentSize.smaller.r,
            // ),
          );
        });
  }
}

class _ManageCollaboratorsOption extends StatelessWidget {
  const _ManageCollaboratorsOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, bool>(
        selector: (_, model) => model.canShowManageCollaboratorsOption,
        builder: (_, canShow, __) {
          if (!canShow) return const SizedBox.shrink();
          return BottomSheetTile(
            iconPath: Assets.iconFriends,
            margin: margin,
            onTap: onTap,
            text: text,
            // trailing: SubscriptionRequirementIndicator(
            //   feature: SubscriptionFeature.playlistCollaboration,
            //   size: ComponentSize.smaller.r,
            // ),
          );
        });
  }
}

class _EditPlaylistOption extends StatelessWidget {
  const _EditPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, bool>(
        selector: (_, model) => model.canShowEditOption,
        builder: (_, canShow, __) {
          if (!canShow) return const SizedBox.shrink();
          return BottomSheetTile(
              iconPath: Assets.iconEdit,
              margin: margin,
              text: text,
              onTap: onTap);
        });
  }
}

class _DownloadPlaylistOption extends StatelessWidget {
  const _DownloadPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTile(
        iconPath: Assets.iconDownload,
        margin: margin,
        text: text,
        onTap: onTap);
  }
}

class _SharePlaylistOption extends StatelessWidget {
  const _SharePlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTile(
        iconPath: Assets.iconShare, margin: margin, text: text, onTap: onTap);
  }
}

class _ReportPlaylistOption extends StatelessWidget {
  const _ReportPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistOptionsModel, bool>(
        selector: (_, model) => model.canShowReportPlaylistOption,
        builder: (_, canShow, __) {
          if (!canShow) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: margin,
              text: text,
              onTap: onTap);
        });
  }
}

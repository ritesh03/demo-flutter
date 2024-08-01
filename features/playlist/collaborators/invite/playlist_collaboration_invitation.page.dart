import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.args.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import '../playlist_collaborator.widget.dart';
import 'playlist_collaboration_invitation.model.dart';

class PlaylistCollaborationInvitationPage extends StatefulWidget {
  const PlaylistCollaborationInvitationPage({Key? key}) : super(key: key);

  @override
  State<PlaylistCollaborationInvitationPage> createState() =>
      _PlaylistCollaborationInvitationPageState();
}

class _PlaylistCollaborationInvitationPageState
    extends PageState<PlaylistCollaborationInvitationPage> {
  //=
  late ScrollController _scrollController;

  PlaylistCollaborationInvitationModel get _playlistModel =>
      context.read<PlaylistCollaborationInvitationModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _playlistModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    final localization = LocaleResources.of(context);

    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: PageTitleBarText(
              text: localization.inviteFriendsPageTitle,
              color: DynamicTheme.get(context).white(),
              onTap: _scrollController.animateToTop),
          centerTitle: true,
          actions: const [],
          child: Column(children: [
            const _PageTopBar(),
            Expanded(
              child: _PageBody(
                controller: _scrollController,
                header: Padding(
                    padding: padding,
                    child: _PageHeader(
                      titleText: localization.inviteFriendsPageTitle,
                      subtitleText: localization.inviteFriendsPageSubtitle,
                      searchHintText: localization.inviteFriendsPageSearchHint,
                      onSearchQueryChanged: _playlistModel.updateSearchQuery,
                      onSearchQueryCleared: _playlistModel.clearSearchQuery,
                    )),
                padding: padding,
                onToggleModerationAccess: _onTogglePlaylistModerationAccess,
                onToggleViewAccess: _onTogglePlaylistViewAccess,
              ),
            ),
            _PageFooter(
              primaryButton: _SendInvitesButton(
                text: localization.sendInvitesButtonText,
                onTap: _onSendInvitesTap,
              ),
              secondaryButton: _UnselectAllButton(
                text: localization.unselectAll,
                onTap: _playlistModel.unselectAll,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _onTogglePlaylistModerationAccess(PlaylistCollaborator collaborator) {
    _playlistModel.togglePlaylistModerationAccess(collaborator.id);
  }

  void _onTogglePlaylistViewAccess(PlaylistCollaborator collaborator) {
    _playlistModel.togglePlaylistViewAccess(collaborator.id);
  }

  void _onSendInvitesTap() async {
    showBlockingProgressDialog(context);
    final result = await _playlistModel.sendInvites();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      if (result.errorCode() ==
          ErrorCodes.playlistCollaboratorInvitationCannotBeEmpty) {
        final errorMessage = LocaleResources.of(context)
            .errorPlaylistCollaboratorInvitationIsEmpty;
        showDefaultNotificationBar(
            NotificationBarInfo.error(message: errorMessage));
        return;
      }

      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    if (_playlistModel.isFromManageCollaboratorsPage) {
      DashboardNavigation.pop(context);
    } else {
      final playlistId = _playlistModel.playlistId;
      DashboardNavigation.pushReplacementNamed(
        context,
        Routes.managePlaylistCollaborators,
        arguments: ManagePlaylistCollaboratorsArgs(playlistId: playlistId),
      );
    }
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
    ]);
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    Key? key,
    required this.titleText,
    required this.subtitleText,
    required this.searchHintText,
    required this.onSearchQueryChanged,
    required this.onSearchQueryCleared,
  }) : super(key: key);

  final String titleText;
  final String subtitleText;
  final String searchHintText;
  final Function(String) onSearchQueryChanged;
  final VoidCallback onSearchQueryCleared;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PageTitle(text: titleText),
      SizedBox(height: ComponentInset.normal.r),
      _PageSubtitle(text: subtitleText),
      SizedBox(height: ComponentInset.medium.r),
      SearchBar(
        hintText: searchHintText,
        onQueryChanged: onSearchQueryChanged,
        onQueryCleared: onSearchQueryCleared,
      ),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()),
        textAlign: TextAlign.left);
  }
}

class _PageSubtitle extends StatelessWidget {
  const _PageSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyles.body
            .copyWith(color: DynamicTheme.get(context).neutral20()),
        textAlign: TextAlign.left);
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({
    Key? key,
    required this.controller,
    required this.header,
    required this.padding,
    required this.onToggleModerationAccess,
    required this.onToggleViewAccess,
  }) : super(key: key);

  final ScrollController controller;
  final Widget header;
  final EdgeInsets padding;
  final Function(PlaylistCollaborator) onToggleModerationAccess;
  final Function(PlaylistCollaborator) onToggleViewAccess;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<PlaylistCollaborator,
            PlaylistCollaborationInvitationModel>(
        controller: controller,
        columnItemSpacing: ComponentInset.normal.r,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        headerSlivers: [SliverToBoxAdapter(child: header)],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, collaborator, index) {
          return PlaylistCollaboratorListItem(
            collaborator: collaborator,
            onToggleModerationAccess: () =>
                onToggleModerationAccess(collaborator),
            onToggleViewAccess: () => onToggleViewAccess(collaborator),
          );
        });
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({
    Key? key,
    required this.primaryButton,
    required this.secondaryButton,
  }) : super(key: key);

  final Widget primaryButton;
  final Widget secondaryButton;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistCollaborationInvitationModel, bool>(
        selector: (_, model) => model.selectedCollaboratorsCount > 0,
        builder: (_, hasSelections, __) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 230),
            child: Container(
                height: hasSelections ? 80.r : 0,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: DynamicTheme.get(context).neutral80(),
                    boxShadow: BoxShadows.footerButtonsOnBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ComponentRadius.normal.r),
                      topRight: Radius.circular(ComponentRadius.normal.r),
                    )),
                padding: EdgeInsets.only(
                    top: ComponentInset.normal.r,
                    bottom: ComponentInset.normal.r,
                    right: ComponentInset.normal.r),
                child: Row(children: [
                  Expanded(flex: 2, child: secondaryButton),
                  Expanded(flex: 3, child: primaryButton)
                ])),
          );
        });
  }
}

class _SendInvitesButton extends StatelessWidget {
  const _SendInvitesButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        height: ComponentSize.large.r,
        text: text,
        type: ButtonType.primary,
        onPressed: onTap);
  }
}

class _UnselectAllButton extends StatelessWidget {
  const _UnselectAllButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        height: ComponentSize.large.r,
        text: text,
        type: ButtonType.text,
        onPressed: onTap);
  }
}

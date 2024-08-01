import 'dart:math' as math;

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/collaborators/invite/playlist_collaboration_invitation.args.dart';
import 'package:kwotmusic/features/playlist/collaborators/playlist_collaborator.widget.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_enforcement.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'manage_playlist_collaborators.model.dart';
import 'remove_all_playlist_collaborators_confirmation.bottomsheet.dart';

class ManagePlaylistCollaboratorsPage extends StatefulWidget {
  const ManagePlaylistCollaboratorsPage({Key? key}) : super(key: key);

  @override
  State<ManagePlaylistCollaboratorsPage> createState() =>
      _ManagePlaylistCollaboratorsPageState();
}

class _ManagePlaylistCollaboratorsPageState
    extends PageState<ManagePlaylistCollaboratorsPage> {
  //=
  late ScrollController _scrollController;

  ManagePlaylistCollaboratorsModel get _collaboratorsModel =>
      context.read<ManagePlaylistCollaboratorsModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _collaboratorsModel.init();
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
              text: localization.manageCollaboratorsPageTitle,
              color: DynamicTheme.get(context).white(),
              onTap: _scrollController.animateToTop),
          centerTitle: true,
          actions: const [],
          child: Column(children: [
            _PageTopBar(onInviteFriendsTap: _onInviteFriendsTap),
            Expanded(
              child: _PageItemsListContainer(
                controller: _scrollController,
                header: _PageHeader(
                  titleText: localization.manageCollaboratorsPageTitle,
                  subtitleText: localization.manageCollaboratorsPageSubtitle,
                  searchHintText:
                      localization.manageCollaboratorsPageSearchHint,
                  onSearchQueryChanged: _collaboratorsModel.updateSearchQuery,
                  onSearchQueryCleared: _collaboratorsModel.clearSearchQuery,
                ),
                padding: padding,
                onRefresh: _collaboratorsModel.onRefresh,
                onToggleModerationAccess: _onTogglePlaylistModerationAccess,
                onToggleViewAccess: _onTogglePlaylistViewAccess,
              ),
            ),
            _PageFooter(
              primaryButton: _UpdateCollaboratorsButton(
                text: localization.updateCollaboratorsButtonText,
                onTap: _onUpdateCollaboratorsTap,
              ),
              secondaryButton: _RemoveAllButton(
                text: localization.removeAll,
                onTap: _onRemoveAllButtonTap,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _onInviteFriendsTap() {
  /*  final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "share-playlists-with-friends", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowManageCollaboration
    );
    if (!fulfilled) return;*/
    DashboardNavigation.pushNamed(
      context,
      Routes.playlistCollaborationInvitation,
      arguments: PlaylistCollaborationInvitationArgs(
        playlistId: _collaboratorsModel.playlistId,
        isFromManageCollaboratorsPage: true,
      ),
    );
  }

  void _onTogglePlaylistModerationAccess(PlaylistCollaborator collaborator) {
    _collaboratorsModel.togglePlaylistModerationAccess(collaborator.id);
  }

  void _onTogglePlaylistViewAccess(PlaylistCollaborator collaborator) {
    _collaboratorsModel.togglePlaylistViewAccess(collaborator.id);
  }

  void _onUpdateCollaboratorsTap() async {
    showBlockingProgressDialog(context);
    final result = await _collaboratorsModel.updateCollaborators();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      if (result.errorCode() == ErrorCodes.somethingWentWrong) {
        final errorMessage = LocaleResources.of(context).somethingWentWrong;
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
  }

  void _onRemoveAllButtonTap() async {
    bool? shouldRemove =
        await RemoveAllPlaylistCollaboratorsConfirmationBottomSheet.show(
            context);
    if (!mounted) return;
    if (shouldRemove == null || !shouldRemove) {
      return;
    }

    _collaboratorsModel.removeAll();
    _onUpdateCollaboratorsTap();
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({
    Key? key,
    required this.onInviteFriendsTap,
  }) : super(key: key);

  final VoidCallback onInviteFriendsTap;

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
      Button(
          height: ComponentSize.small.r,
          onPressed: onInviteFriendsTap,
          text: LocaleResources.of(context).inviteFriends,
          type: ButtonType.text),
      SizedBox(width: ComponentInset.normal.r),
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

class _PageItemsListContainer extends StatelessWidget {
  const _PageItemsListContainer({
    Key? key,
    required this.controller,
    required this.header,
    required this.padding,
    required this.onRefresh,
    required this.onToggleModerationAccess,
    required this.onToggleViewAccess,
  }) : super(key: key);

  final ScrollController controller;
  final Widget header;
  final EdgeInsets padding;
  final VoidCallback onRefresh;
  final Function(PlaylistCollaborator) onToggleModerationAccess;
  final Function(PlaylistCollaborator) onToggleViewAccess;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(child: Padding(padding: padding, child: header)),
        SliverPadding(
            padding: padding,
            sliver: _PageItemsList(
              onRefresh: onRefresh,
              onToggleModerationAccess: onToggleModerationAccess,
              onToggleViewAccess: onToggleViewAccess,
            )),
        DashboardConfigAwareFooter.asSliver(),
      ],
    );
  }
}

class _PageItemsList extends StatelessWidget {
  const _PageItemsList({
    Key? key,
    required this.onRefresh,
    required this.onToggleModerationAccess,
    required this.onToggleViewAccess,
  }) : super(key: key);

  final VoidCallback onRefresh;
  final Function(PlaylistCollaborator) onToggleModerationAccess;
  final Function(PlaylistCollaborator) onToggleViewAccess;

  @override
  Widget build(BuildContext context) {
    return Selector<ManagePlaylistCollaboratorsModel,
            Result<List<PlaylistCollaborator>>?>(
        selector: (_, model) => model.collaboratorsResult,
        builder: (_, result, __) {
          if (result == null) {
            return const SliverFillRemaining(child: LoadingIndicator());
          }

          if (!result.isSuccess()) {
            return SliverFillRemaining(
              child: ErrorIndicator(
                error: result.error(),
                onTryAgain: onRefresh,
              ),
            );
          }

          final items = result.peek();
          if (items == null || items.isEmpty) {
            return const SliverFillRemaining(child: EmptyIndicator());
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, iterationIndex) {
                if (iterationIndex.isOdd) {
                  return SizedBox(height: ComponentInset.normal.r);
                }

                final itemIndex = iterationIndex ~/ 2;
                final collaborator = items[itemIndex];
                return PlaylistCollaboratorListItem(
                  collaborator: collaborator,
                  onToggleModerationAccess: () =>
                      onToggleModerationAccess(collaborator),
                  onToggleViewAccess: () => onToggleViewAccess(collaborator),
                );
              },
              semanticIndexCallback: (_, iterationIndex) {
                return iterationIndex.isEven ? (iterationIndex ~/ 2) : null;
              },
              childCount: math.max(0, items.length * 2 - 1),
            ),
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
    return Selector<ManagePlaylistCollaboratorsModel, bool>(
        selector: (_, model) => model.totalCollaborators > 0,
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

class _UpdateCollaboratorsButton extends StatelessWidget {
  const _UpdateCollaboratorsButton({
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

class _RemoveAllButton extends StatelessWidget {
  const _RemoveAllButton({
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

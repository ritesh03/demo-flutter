import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/photochooserselectionsheet/photo_chooser_selection_sheet.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/delete/delete_playlist_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.args.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:kwotmusic/util/validation_util.dart';
import 'package:provider/provider.dart';

import 'create_edit_playlist.model.dart';

class CreateEditPlaylistPage extends StatefulWidget {
  const CreateEditPlaylistPage({Key? key}) : super(key: key);

  @override
  State<CreateEditPlaylistPage> createState() => _CreateEditPlaylistPageState();
}

class _CreateEditPlaylistPageState extends PageState<CreateEditPlaylistPage> {
  //=

  CreateEditPlaylistModel get _model => context.read<CreateEditPlaylistModel>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar()),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TitleText(),
                    SizedBox(height: ComponentInset.normal.h),
                    _buildPhotoSection(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildNameInput(),
                    SizedBox(height: ComponentInset.medium.h),
                    _buildDescriptionInput(),
                    SizedBox(height: ComponentInset.medium.h),
                    _DeletePlaylistButton(onTap: _onDeleteButtonTapped),
                    SizedBox(height: ComponentInset.medium.h),
                    const DashboardConfigAwareFooter()
                  ],
                ))),
      ),
    );
  }

  Widget _buildAppBar() {
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
          text: LocaleResources.of(context).save,
          type: ButtonType.text,
          height: ComponentSize.smaller.h,
          onPressed: _onSaveButtonTapped),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildPhotoSection() {
    final size = 160.r;
    final borderRadius = BorderRadius.circular(ComponentRadius.normal.r);
    return ScaleTap(
      scaleMinValue: 0.98,
      onPressed: _onPlaylistPhotoButtonTapped,
      child: SizedBox(
          width: size,
          height: size,
          child: Selector<CreateEditPlaylistModel, String?>(
              selector: (_, model) => model.playlistPhotoPath,
              builder: (_, playlistPhotoPath, __) {
                if (playlistPhotoPath == null) {
                  return const _EmptyPlaylistPhoto();
                }

                return Photo.playlist(playlistPhotoPath,
                    options: PhotoOptions(
                      width: size,
                      height: size,
                      borderRadius: borderRadius,
                    ));
              })),
    );
  }

  Widget _buildNameInput() {
    return Selector<CreateEditPlaylistModel, String?>(
        selector: (_, model) => model.nameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: _model.nameTextController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).playlistNameInputHint,
            inputFormatters: ValidationUtil.text.playlistNameInputFormatters,
            labelText: LocaleResources.of(context).playlistNameInputLabel,
            onChanged: _model.onNameInputChanged,
            textCapitalization:
                ValidationUtil.text.playlistNameInputCapitalization,
          );
        });
  }

  Widget _buildDescriptionInput() {
    return TextInputField(
      controller: _model.descriptionTextController,
      height: 140.h,
      hintText: LocaleResources.of(context).playlistDescriptionInputHint,
      inputBoxCrossAxisAlignment: CrossAxisAlignment.start,
      inputBoxPadding: EdgeInsets.symmetric(vertical: ComponentInset.small.r),
      inputFormatters: ValidationUtil.text.playlistDescriptionInputFormatters,
      keyboardType: TextInputType.multiline,
      labelText: LocaleResources.of(context).playlistDescriptionInputLabel,
      maxLines: null,
      minLines: 5,
    );
  }

  /*
   * ACTIONS
   */

  void _onPlaylistPhotoButtonTapped() async {
    hideKeyboard(context);

    final PhotoChooser? chooser = await PhotoChooserSelectionSheet.show(
      context,
      title: LocaleResources.of(context).playlistAddPhoto,
    );

    if (!mounted) return;
    if (chooser != null) {
      _model.pickPhoto(chooser);
    }
  }

  void _onSaveButtonTapped() async {
    hideKeyboard(context);

    showBlockingProgressDialog(context);
    final result = await _model.submitPlaylist(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result == null) return;

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    if (_model.isEditingPlaylist) {
      if (_model.isOnPlaylistPage) {
        DashboardNavigation.pop(context);
        return;
      }

      final playlist = result.data();
      DashboardNavigation.pushReplacementNamed(
        context,
        Routes.playlist,
        arguments: PlaylistArgs(
          id: playlist.id,
          title: playlist.name,
          thumbnail: playlist.images.isEmpty ? null : playlist.images.first,
        ),
      );
    }

    if (_model.hasInitialTrackOrAlbum) {
      final playlist = result.data();
      DashboardNavigation.pushReplacementNamed(
        context,
        Routes.playlist,
        arguments: PlaylistArgs(
          id: playlist.id,
          title: playlist.name,
          thumbnail: playlist.images.isEmpty ? null : playlist.images.first,
        ),
      );
      return;
    }

    final playlist = result.data();
    DashboardNavigation.pushReplacementNamed(
      context,
      Routes.playlistAddTracks,
      arguments: PlaylistAddTracksArgs(
        playlist: playlist,
        isOnPlaylistPage: false,
      ),
    );
  }

  void _onDeleteButtonTapped() async {
    hideKeyboard(context);

    bool? shouldDelete =
        await DeletePlaylistConfirmationBottomSheet.show(context);
    if (!mounted) return;
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    showBlockingProgressDialog(context);
    final result = await _model.deletePlaylist(context);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    DashboardNavigation.pop(context);
  }
}

class _EmptyPlaylistPhoto extends StatelessWidget {
  const _EmptyPlaylistPhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: DynamicTheme.get(context).secondary60(),
      strokeWidth: 2.r,
      dashPattern: const [4],
      borderType: BorderType.RRect,
      radius: Radius.circular(ComponentRadius.normal.r),
      child: Center(
        child: SvgAssetPhoto(
          Assets.iconAddMedium,
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          color: DynamicTheme.get(context).secondary120(),
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<CreateEditPlaylistModel, bool>(
        selector: (_, model) => model.isEditingPlaylist,
        builder: (_, isEditingPlaylist, __) {
          return Container(
              height: ComponentSize.small.h,
              alignment: Alignment.centerLeft,
              child: Text(
                  isEditingPlaylist
                      ? LocaleResources.of(context).playlistEditPageTitle
                      : LocaleResources.of(context).playlistCreatePageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldHeading2));
        });
  }
}

class _DeletePlaylistButton extends StatelessWidget {
  const _DeletePlaylistButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<CreateEditPlaylistModel, bool>(
        selector: (_, model) => model.isEditingPlaylist,
        builder: (_, isEditingPlaylist, __) {
          if (!isEditingPlaylist) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.center,
            child: AppIconTextButton(
              height: ComponentSize.smaller.r,
              iconPath: Assets.iconDelete,
              iconSize: ComponentSize.smaller.r,
              iconTextSpacing: ComponentInset.small.r,
              text: LocaleResources.of(context).playlistDelete,
              textStyle: TextStyles.boldHeading5,
              color: DynamicTheme.get(context).neutral10(),
              onPressed: onTap,
            ),
          );
        });
  }
}

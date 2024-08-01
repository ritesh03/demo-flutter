import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:image_picker/image_picker.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/ext/playlist_ext.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/photochooserselectionsheet/photo_chooser_selection_sheet.widget.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';

abstract class CreateEditPlaylistArgs {}

class CreatePlaylistArgs extends CreateEditPlaylistArgs {
  CreatePlaylistArgs({
    this.initialTrack,
    this.initialAlbum,
  });

  final Track? initialTrack;
  final Album? initialAlbum;
}

class EditPlaylistArgs extends CreateEditPlaylistArgs {
  EditPlaylistArgs({
    required this.playlist,
    this.isOnPlaylistPage = false,
  });

  final Playlist playlist;
  final bool isOnPlaylistPage;
}

class CreateEditPlaylistModel with ChangeNotifier {
  //=
  static const bool _defaultPublicStatus = false;

  CreatePlaylistArgs? _createPlaylistArgs;
  EditPlaylistArgs? _editPlaylistArgs;

  TextEditingController nameTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();

  CreateEditPlaylistModel({
    CreateEditPlaylistArgs? args,
  }) {
    if (args is CreatePlaylistArgs) {
      _createPlaylistArgs = args;
      return;
    }

    if (args is EditPlaylistArgs) {
      final playlist = args.playlist;
      if (playlist.isOwnedByCurrentUser()) {
        _editPlaylistArgs = args;
        nameTextController.text = playlist.name;
        descriptionTextController.text = playlist.description ?? "";
      }
      return;
    }

    _createPlaylistArgs = CreatePlaylistArgs();
  }

  final ImagePicker _picker = ImagePicker();

  bool get isEditingPlaylist => _editPlaylistArgs != null;

  bool get isOnPlaylistPage =>
      _editPlaylistArgs != null && _editPlaylistArgs!.isOnPlaylistPage;

  bool get hasInitialTrackOrAlbum {
    return _createPlaylistArgs?.initialTrack != null ||
        _createPlaylistArgs?.initialAlbum != null;
  }

  String? get playlistPhotoPath {
    final selectedPhoto = _selectedPlaylistPhoto;
    if (selectedPhoto != null) {
      return selectedPhoto.path;
    }

    final playlist = _editPlaylistArgs?.playlist;
    if (playlist != null) {
      return playlist.images.isEmpty ? null : playlist.images.first;
    }

    return null;
  }

  /*
   * Name Input
   */

  String? _nameInputError;

  String? get nameInputError => _nameInputError;

  void onNameInputChanged(String text) {
    _notifyNameInputError(null);
  }

  void _notifyNameInputError(String? error) {
    _nameInputError = error;
    notifyListeners();
  }

  /*
   * PHOTO
   */

  File? _selectedPlaylistPhoto;

  void pickPhoto(PhotoChooser chooser) async {
    final ImageSource imageSource;
    switch (chooser) {
      case PhotoChooser.camera:
        imageSource = ImageSource.camera;
        break;
      case PhotoChooser.gallery:
        imageSource = ImageSource.gallery;
        break;
    }

    final pickedFile = await _picker.pickImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (pickedFile == null) {
      return;
    }

    _selectedPlaylistPhoto = File(pickedFile.path);
    notifyListeners();
  }

  /*
   * API: CREATE / EDIT PLAYLIST
   */

  Future<Result<Playlist>?> submitPlaylist(BuildContext context) async {
    final localization = LocaleResources.of(context);

    final nameInput = nameTextController.text.trim();
    final descriptionInput = descriptionTextController.text.trim();

    // Validate Name
    String? nameInputError;
    if (nameInput.isEmpty) {
      nameInputError = localization.errorEnterPlaylistName;
    }
    _notifyNameInputError(nameInputError);

    if (nameInputError != null) {
      // One of the validations failed.
      return null;
    }

    final playlistPhoto = _selectedPlaylistPhoto;
    if (playlistPhoto != null && !playlistPhoto.existsSync()) {
      return Result.error(localization.errorSelectedPhotoDoesNotExist);
    }

    if (isEditingPlaylist) {
      return _updatePlaylist(
        name: nameInput,
        description: descriptionInput,
        photoFile: _selectedPlaylistPhoto,
        isPublic: _defaultPublicStatus,
      );
    }

    return _createPlaylist(
      name: nameInput,
      description: descriptionInput,
      photoFile: playlistPhoto,
      isPublic: _defaultPublicStatus,
    );
  }

  Future<Result<Playlist>> _createPlaylist({
    required String name,
    required String? description,
    required File? photoFile,
    required bool isPublic,
  }) {
    final request = CreatePlaylistRequest(
      name: name,
      description: description,
      photoFile: photoFile,
      public: isPublic,
      initialTrack: _createPlaylistArgs?.initialTrack,
      initialAlbum: _createPlaylistArgs?.initialAlbum,
    );
    return locator<KwotData>().playlistsRepository.createPlaylist(request);
  }

  Future<Result<Playlist>> _updatePlaylist({
    required String name,
    required String? description,
    required File? photoFile,
    required bool isPublic,
  }) async {
    final playlist = _editPlaylistArgs!.playlist;
    final updatedName = (playlist.name != name) ? name : null;
    final updatedDescription =
        (playlist.description != description) ? description : null;
    final updatedPhotoFile = (photoFile != null) ? photoFile : null;
    final updatedPublicStatus = (playlist.public != isPublic) ? isPublic : null;

    final request = UpdatePlaylistRequest(
      playlistId: playlist.id,
      updatedName: updatedName,
      updatedDescription: updatedDescription,
      updatedPhotoFile: updatedPhotoFile,
      updatedPublicStatus: updatedPublicStatus,
    );

    final result =
        await locator<KwotData>().playlistsRepository.updatePlaylist(request);
    if (result.isSuccess() && !result.isEmpty()) {
      eventBus.fire(
        PlaylistUpdatedEvent(playlist: result.data()),
      );
    }

    return result;
  }

  /*
   * API: DELETE PLAYLIST
   */

  Future<Result> deletePlaylist(BuildContext context) async {
    final playlist = _editPlaylistArgs?.playlist;
    if (playlist == null) {
      return Result.error("Unable to delete unknown playlist");
    }

    final request = DeletePlaylistRequest(id: playlist.id);
    final result =
        await locator<KwotData>().playlistsRepository.deletePlaylist(request);
    if (result.isSuccess()) {
      eventBus.fire(
        PlaylistDeletedEvent(playlistId: playlist.id),
      );
    }

    return result;
  }
}

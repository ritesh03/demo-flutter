import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/events/events.dart';

import 'manage_playlist_collaborators.args.dart';

class ManagePlaylistCollaboratorsModel
    with ChangeNotifier, OnRefreshMixin, SearchQueryMixin {
  //=
  final String _playlistId;

  async.CancelableOperation<Result<List<PlaylistCollaborator>>>?
      _collaboratorsOp;
  Result<List<PlaylistCollaborator>>? _collaboratorsResult;
  Result<List<PlaylistCollaborator>>? _filteredCollaboratorsResult;

  late final StreamSubscription _eventsSubscription;

  ManagePlaylistCollaboratorsModel({
    required ManagePlaylistCollaboratorsArgs args,
  }) : _playlistId = args.playlistId {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    _fetchCollaborators();
  }

  String get playlistId => _playlistId;

  Result<List<PlaylistCollaborator>>? get collaboratorsResult =>
      _filteredCollaboratorsResult ?? _collaboratorsResult;

  List<PlaylistCollaborator> get _collaborators =>
      _collaboratorsResult?.peek() ?? [];

  int get totalCollaborators => _collaborators.length;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _collaboratorsOp?.cancel();
    super.dispose();
  }

  Future<void> _fetchCollaborators({
    bool forceRefresh = false,
  }) async {
    try {
      // Cancel current operation (if any)
      _collaboratorsOp?.cancel();
      _filteredCollaboratorsResult = null;

      if (!forceRefresh &&
          _collaboratorsResult != null &&
          _collaborators.isEmpty) {
        _collaboratorsResult = null;
        notifyListeners();
      }

      if (forceRefresh || _collaborators.isEmpty) {
        // Create Request
        final request = PlaylistCollaboratorsRequest(playlistId: _playlistId);
        _collaboratorsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().playlistsRepository.fetchCollaborators(request),
        );

        // Listen for result
        _collaboratorsResult = await _collaboratorsOp?.value;
      }

      _updateFilteredCollaborators();
    } catch (error) {
      _filteredCollaboratorsResult = null;
      _collaboratorsResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  Future<void> refresh() {
    return _fetchCollaborators(forceRefresh: true);
  }

  void _updateFilteredCollaborators() {
    final collaborators = _collaborators;
    if (collaborators.isEmpty) {
      _filteredCollaboratorsResult = null;
      return;
    }

    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      _filteredCollaboratorsResult = null;
      return;
    }

    final query = searchQuery!;
    _filteredCollaboratorsResult = Result.success(
      collaborators.where((collaborator) {
        return collaborator.name.toLowerCase().contains(query.toLowerCase());
      }).toList(),
    );
  }

  /*
   * OnRefresh
   */

  @override
  void onRefresh() {
    _fetchCollaborators();
  }

  void togglePlaylistViewAccess(String collaboratorId) {
    final collaborators = _collaborators.map((collaborator) {
      if (collaborator.id == collaboratorId) {
        return collaborator.copyWith(
          canView: !collaborator.canView,
          canEditItems: false,
        );
      }
      return collaborator;
    }).toList();

    _collaboratorsResult = Result.success(collaborators);
    _updateFilteredCollaborators();
    notifyListeners();
  }

  void togglePlaylistModerationAccess(String collaboratorId) {
    final collaborators = _collaborators.map((collaborator) {
      if (collaborator.id == collaboratorId) {
        return collaborator.copyWith(
          canView: true,
          canEditItems: !collaborator.canEditItems,
        );
      }
      return collaborator;
    }).toList();

    _collaboratorsResult = Result.success(collaborators);
    _updateFilteredCollaborators();
    notifyListeners();
  }

  Future<Result> updateCollaborators() async {
    try {
      final collaborators = _collaborators;
      if (collaborators.isEmpty) {
        return Result.error(
          'Something went wrong.',
          errorCode: ErrorCodes.somethingWentWrong,
        );
      }

      final request = UpdatePlaylistCollaboratorsRequest(
          playlistId: _playlistId, collaborators: collaborators);
      final result = await locator<KwotData>()
          .playlistsRepository
          .updateCollaborators(request);
      if (result.isSuccess() && !result.isEmpty()) {
        final status = result.data();
        eventBus.fire(
          PlaylistCollaboratorsCountUpdatedEvent(
            playlistId: status.playlistId,
            totalCollaborators: status.totalCollaborators,
          ),
        );
      }

      return result;
    } catch (error) {
      return Result.error(error.toString());
    }
  }

  void removeAll() {
    final collaborators = _collaborators.map((collaborator) {
      if (collaborator.canView || collaborator.canEditItems) {
        return collaborator.copyWith(
          canView: false,
          canEditItems: false,
        );
      }
      return collaborator;
    }).toList();

    _collaboratorsResult = Result.success(collaborators);
    _updateFilteredCollaborators();
    notifyListeners();
  }

  /*
   * EVENT:
   *  PlaylistCollaboratorsCountUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PlaylistCollaboratorsCountUpdatedEvent) {
        return _handlePlaylistCollaboratorsCountUpdatedEvent(event);
      }
    });
  }

  void _handlePlaylistCollaboratorsCountUpdatedEvent(
    PlaylistCollaboratorsCountUpdatedEvent event,
  ) {
    _collaboratorsResult = null;
    _filteredCollaboratorsResult = null;
    notifyListeners();

    _fetchCollaborators(forceRefresh: true);
  }
}

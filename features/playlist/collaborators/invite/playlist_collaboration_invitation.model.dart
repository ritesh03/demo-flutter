import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'playlist_collaboration_invitation.args.dart';

class PlaylistCollaborationInvitationModel
    with
        ChangeNotifier,
        ItemListModel<PlaylistCollaborator>,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  final String _playlistId;
  final bool _isFromManageCollaboratorsPage;
  final Map<String, PlaylistCollaborator> _selectedCollaboratorsMap = {};

  async.CancelableOperation<Result<ListPage<User>>>? _suggestedUsersOp;
  late final PagingController<int, PlaylistCollaborator>
      _collaboratorsController;

  late final StreamSubscription _eventsSubscription;

  PlaylistCollaborationInvitationModel({
    required PlaylistCollaborationInvitationArgs args,
  })  : _playlistId = args.playlistId,
        _isFromManageCollaboratorsPage = args.isFromManageCollaboratorsPage {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    _collaboratorsController =
        PagingController<int, PlaylistCollaborator>(firstPageKey: 1);
    _collaboratorsController.addPageRequestListener((pageKey) {
      _fetchSuggestedUsers(pageKey);
    });
  }

  String get playlistId => _playlistId;

  bool get isFromManageCollaboratorsPage => _isFromManageCollaboratorsPage;

  int get selectedCollaboratorsCount {
    return _selectedCollaboratorsMap.length;
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _suggestedUsersOp?.cancel();
    _collaboratorsController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestedUsers(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _suggestedUsersOp?.cancel();

      // Create Request
      final request = PlaylistSuggestedCollaborationUsersRequest(
        playlistId: _playlistId,
        page: pageKey,
        query: searchQuery,
      );
      _suggestedUsersOp = async.CancelableOperation.fromFuture(
        locator<KwotData>()
            .playlistsRepository
            .fetchSuggestedCollaborationUsers(request),
        onCancel: () {
          _collaboratorsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _suggestedUsersOp?.value.then((result) {
        if (!result.isSuccess()) {
          _collaboratorsController.error = result.error();
          return;
        }

        final page = result.data();
        final suggestedCollaborators = page.items!.map((user) {
          return PlaylistCollaborator(
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            photo: user.thumbnail,
            playlistId: _playlistId,
            capabilities: PlaylistCapabilities.none(),
          );
        }).toList();

        final currentItemCount = _collaboratorsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _collaboratorsController.appendLastPage(suggestedCollaborators);
        } else {
          final nextPageKey = pageKey + 1;
          _collaboratorsController.appendPage(
              suggestedCollaborators, nextPageKey);
        }
      });
    } catch (error) {
      _collaboratorsController.error = error;
    }
  }

  /*
   * OnRefresh
   */

  @override
  void onRefresh() {
    _collaboratorsController.refresh();
  }

  /*
   * ItemListModel<Podcast>
   */

  @override
  PagingController<int, PlaylistCollaborator> controller() =>
      _collaboratorsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _suggestedUsersOp?.cancel();

    if (resetPageKey) {
      _collaboratorsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _collaboratorsController.retryLastFailedRequest();
    }
  }

  void togglePlaylistViewAccess(String collaboratorId) {
    _collaboratorsController.updateItems<PlaylistCollaborator>(
      (index, collaborator) {
        if (collaborator.id != collaboratorId) return collaborator;

        final updatedCollaborator = collaborator.copyWith(
          canView: !collaborator.canView,
          canEditItems: false,
        );
        _updateSelectedCollaboratorsMap(updatedCollaborator);
        return updatedCollaborator;
      },
    );
    notifyListeners();
  }

  void togglePlaylistModerationAccess(String collaboratorId) {
    _collaboratorsController.updateItems<PlaylistCollaborator>(
      (index, collaborator) {
        if (collaborator.id != collaboratorId) return collaborator;

        final updatedCollaborator = collaborator.copyWith(
          canView: true,
          canEditItems: !collaborator.canEditItems,
        );
        _updateSelectedCollaboratorsMap(updatedCollaborator);
        return updatedCollaborator;
      },
    );
  }

  Future<Result> sendInvites() async {
    try {
      final playlistId = _playlistId;
      final selectedCollaborators = _selectedCollaboratorsMap.values
          .where((collaborator) => collaborator.canView)
          .toList();
      if (selectedCollaborators.isEmpty) {
        return Result.error(
          'Something went wrong.',
          errorCode: ErrorCodes.playlistCollaboratorInvitationCannotBeEmpty,
        );
      }

      final request = AddPlaylistCollaboratorsRequest(
          playlistId: playlistId, collaborators: selectedCollaborators);
      final result = await locator<KwotData>()
          .playlistsRepository
          .addCollaborators(request);
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

  void unselectAll() {
    _collaboratorsController.updateItems<PlaylistCollaborator>(
      (index, collaborator) {
        if (collaborator.canView || collaborator.canEditItems) {
          return collaborator.copyWith(
            canView: false,
            canEditItems: false,
          );
        }
        return collaborator;
      },
    );

    _selectedCollaboratorsMap.clear();
    notifyListeners();
  }

  void _updateSelectedCollaboratorsMap(PlaylistCollaborator collaborator) {
    if (collaborator.canView) {
      _selectedCollaboratorsMap[collaborator.id] = collaborator;
    } else {
      _selectedCollaboratorsMap.remove(collaborator.id);
    }
  }

  /*
   * EVENTS
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {});
  }
}

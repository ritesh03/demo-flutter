class PlaylistCollaborationInvitationArgs {
  PlaylistCollaborationInvitationArgs({
    required this.playlistId,
    this.isFromManageCollaboratorsPage = false,
  });

  final String playlistId;
  final bool isFromManageCollaboratorsPage;
}

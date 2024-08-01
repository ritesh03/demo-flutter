import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/misc/unknown_route.widget.dart';
import 'package:kwotmusic/features/activity/list/users_activities.args.dart';
import 'package:kwotmusic/features/activity/list/users_activities.model.dart';
import 'package:kwotmusic/features/activity/list/users_activities.page.dart';
import 'package:kwotmusic/features/album/artists/album_artists.page.dart';
import 'package:kwotmusic/features/album/detail/album.args.dart';
import 'package:kwotmusic/features/album/detail/album.model.dart';
import 'package:kwotmusic/features/album/detail/album.page.dart';
import 'package:kwotmusic/features/album/list/albums.args.dart';
import 'package:kwotmusic/features/album/list/albums.model.dart';
import 'package:kwotmusic/features/album/list/albums.page.dart';
import 'package:kwotmusic/features/artist/fanclubviews/eventMeetGreetView/event_meet_model.dart';
import 'package:kwotmusic/features/artist/fanclubviews/eventMeetGreetView/event_meet_view.dart';
import 'package:kwotmusic/features/artist/fanclubviews/liveshowsview/live_show_view.dart';
import 'package:kwotmusic/features/artist/followers/artist_followers.model.dart';
import 'package:kwotmusic/features/artist/followers/artist_followers.page.dart';
import 'package:kwotmusic/features/artist/followings/artist_followings.model.dart';
import 'package:kwotmusic/features/artist/followings/artist_followings.page.dart';
import 'package:kwotmusic/features/artist/list/artists.model.dart';
import 'package:kwotmusic/features/artist/list/artists.page.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.page.dart';
import 'package:kwotmusic/features/artist/tip/artist_tip.args.dart';
import 'package:kwotmusic/features/artist/tip/artist_tip_page.dart';
import 'package:kwotmusic/features/auth/accountrecovery/phoneverification/phone_verification.model.dart';
import 'package:kwotmusic/features/auth/accountrecovery/phoneverification/phone_verification.page.dart';
import 'package:kwotmusic/features/auth/accountrecovery/request/request_account_recovery.model.dart';
import 'package:kwotmusic/features/auth/accountrecovery/request/request_account_recovery.page.dart';
import 'package:kwotmusic/features/auth/accountrecovery/setpassword/set_password.model.dart';
import 'package:kwotmusic/features/auth/accountrecovery/setpassword/set_password.page.dart';
import 'package:kwotmusic/features/auth/emailverification/email_verification.model.dart';
import 'package:kwotmusic/features/auth/phoneverification/phone_otp_verification.model.dart';
import 'package:kwotmusic/features/auth/signin/sign_in.model.dart';
import 'package:kwotmusic/features/auth/signin/sign_in.page.dart';
import 'package:kwotmusic/features/auth/signup/emailverification/email_sign_up_verification.model.dart';
import 'package:kwotmusic/features/auth/signup/emailverification/email_sign_up_verification.page.dart';
import 'package:kwotmusic/features/auth/signup/phoneverification/phone_sign_up_verification.model.dart';
import 'package:kwotmusic/features/auth/signup/phoneverification/phone_sign_up_verification.page.dart';
import 'package:kwotmusic/features/auth/signup/sign_up.model.dart';
import 'package:kwotmusic/features/auth/signup/sign_up.page.dart';
import 'package:kwotmusic/features/dashboard/dashboard.page.dart';
import 'package:kwotmusic/features/downloads/downloads.model.dart';
import 'package:kwotmusic/features/downloads/downloads.page.dart';
import 'package:kwotmusic/features/misc/contact/contact.model.dart';
import 'package:kwotmusic/features/misc/contact/contact.page.dart';
import 'package:kwotmusic/features/misc/feedback/feedback.model.dart';
import 'package:kwotmusic/features/misc/feedback/feedback.page.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.page.dart';
import 'package:kwotmusic/features/music/browsekind/list/music_browse_kinds.args.dart';
import 'package:kwotmusic/features/music/browsekind/list/music_browse_kinds.model.dart';
import 'package:kwotmusic/features/music/browsekind/list/music_browse_kinds.page.dart';
import 'package:kwotmusic/features/music/browsekindoptions/list/music_browse_kind_options.args.dart';
import 'package:kwotmusic/features/music/browsekindoptions/list/music_browse_kind_options.model.dart';
import 'package:kwotmusic/features/music/browsekindoptions/list/music_browse_kind_options.page.dart';
import 'package:kwotmusic/features/music/browser/music_browser.args.dart';
import 'package:kwotmusic/features/music/browser/music_browser.model.dart';
import 'package:kwotmusic/features/music/browser/music_browser.page.dart';
import 'package:kwotmusic/features/music/genre/onboarding/onboarding_genre_selection.model.dart';
import 'package:kwotmusic/features/music/genre/onboarding/onboarding_genre_selection.page.dart';
import 'package:kwotmusic/features/onboarding/onboarding.model.dart';
import 'package:kwotmusic/features/onboarding/onboarding.page.dart';
import 'package:kwotmusic/features/playlist/collaborators/invite/playlist_collaboration_invitation.args.dart';
import 'package:kwotmusic/features/playlist/collaborators/invite/playlist_collaboration_invitation.model.dart';
import 'package:kwotmusic/features/playlist/collaborators/invite/playlist_collaboration_invitation.page.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.args.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.model.dart';
import 'package:kwotmusic/features/playlist/collaborators/manage/manage_playlist_collaborators.page.dart';
import 'package:kwotmusic/features/playlist/createedit/create_edit_playlist.model.dart';
import 'package:kwotmusic/features/playlist/createedit/create_edit_playlist.page.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.model.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.page.dart';
import 'package:kwotmusic/features/playlist/list/playlists.args.dart';
import 'package:kwotmusic/features/playlist/list/playlists.model.dart';
import 'package:kwotmusic/features/playlist/list/playlists.page.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.args.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.model.dart';
import 'package:kwotmusic/features/playlist/tracks/add/playlist_add_tracks.page.dart';
import 'package:kwotmusic/features/playlist/tracks/playlist_tracks.args.dart';
import 'package:kwotmusic/features/playlist/tracks/playlist_tracks.model.dart';
import 'package:kwotmusic/features/playlist/tracks/playlist_tracks.page.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.model.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.page.dart';
import 'package:kwotmusic/features/podcast/list/podcasts.model.dart';
import 'package:kwotmusic/features/podcast/list/podcasts.page.dart';
import 'package:kwotmusic/features/podcastcategory/list/podcast_categories.model.dart';
import 'package:kwotmusic/features/podcastcategory/list/podcast_categories.page.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.page.dart';
import 'package:kwotmusic/features/podcastepisode/list/podcast_episodes.model.dart';
import 'package:kwotmusic/features/podcastepisode/list/podcast_episodes.page.dart';
import 'package:kwotmusic/features/profile/billingdetails/addedit/addedit_billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/addedit/addedit_billing_details.page.dart';
import 'package:kwotmusic/features/profile/billingdetails/billing_details.model.dart';
import 'package:kwotmusic/features/profile/billingdetails/billing_details.page.dart';
import 'package:kwotmusic/features/profile/blockedusers/blocked_users.model.dart';
import 'package:kwotmusic/features/profile/blockedusers/blocked_users.page.dart';
import 'package:kwotmusic/features/profile/changepassword/change_password.model.dart';
import 'package:kwotmusic/features/profile/changepassword/change_password.page.dart';
import 'package:kwotmusic/features/profile/editprofile/edit_profile.model.dart';
import 'package:kwotmusic/features/profile/editprofile/edit_profile.page.dart';
import 'package:kwotmusic/features/profile/editprofile/emailverification/profile_email_verification.model.dart';
import 'package:kwotmusic/features/profile/editprofile/emailverification/profile_email_verification.page.dart';
import 'package:kwotmusic/features/profile/editprofile/phoneverification/profile_phone_verification.model.dart';
import 'package:kwotmusic/features/profile/editprofile/phoneverification/profile_phone_verification.page.dart';
import 'package:kwotmusic/features/profile/findfriends/find_friends.model.dart';
import 'package:kwotmusic/features/profile/findfriends/find_friends.page.dart';
import 'package:kwotmusic/features/profile/notifications/list/notifications.model.dart';
import 'package:kwotmusic/features/profile/notifications/list/notifications.page.dart';
import 'package:kwotmusic/features/profile/paymenthistory/payment_history.model.dart';
import 'package:kwotmusic/features/profile/paymenthistory/payment_history.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/manage/manage_subscription.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/manage/manage_subscription.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/paymentmethod/subscription_payment_methods.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step1preview/subscription_plan_selection_preview.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step1preview/subscription_plan_selection_preview.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step2details/subscription_plan_purchase_process.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step2details/subscription_plan_purchase_process.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step3payment/subscription_payment.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step3payment/subscription_payment.page.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step4confirmation/subscription_payment_confirmation.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step4confirmation/subscription_payment_confirmation.page.dart';
import 'package:kwotmusic/features/radiostation/list/radio_stations.model.dart';
import 'package:kwotmusic/features/radiostation/list/radio_stations.page.dart';
import 'package:kwotmusic/features/search/search.model.dart';
import 'package:kwotmusic/features/search/search.page.dart';
import 'package:kwotmusic/features/show/countdown/live_show_countdown.model.dart';
import 'package:kwotmusic/features/show/countdown/live_show_countdown.page.dart';
import 'package:kwotmusic/features/show/list/shows.model.dart';
import 'package:kwotmusic/features/show/list/shows.page.dart';
import 'package:kwotmusic/features/skit/list/skits.model.dart';
import 'package:kwotmusic/features/skit/list/skits.page.dart';
import 'package:kwotmusic/features/followers/followers.model.dart';
import 'package:kwotmusic/features/followings/followings.model.dart';
import 'package:kwotmusic/features/track/artists/track_artists.page.dart';
import 'package:kwotmusic/features/track/list/tracks.args.dart';
import 'package:kwotmusic/features/track/list/tracks.model.dart';
import 'package:kwotmusic/features/track/list/tracks.page.dart';
import 'package:kwotmusic/features/user/followers/user_followers.model.dart';
import 'package:kwotmusic/features/user/followers/user_followers.page.dart';
import 'package:kwotmusic/features/user/followings/user_followings.model.dart';
import 'package:kwotmusic/features/user/followings/user_followings.page.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/features/user/profile/user_profile.page.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../features/artist/fanclubviews/activediscounts/active_discounts_model.dart';
import '../features/artist/fanclubviews/activediscounts/active_discounts_view.dart';
import '../features/artist/fanclubviews/exclusiveContentView/exclusive_content_view.dart';
import '../features/artist/fanclubviews/exclusiveContentView/exclusive_content_view_model.dart';
import '../features/artist/fanclubviews/liveshowsview/live_show_model.dart';
import '../features/fans/fans_model.dart';
import '../features/fans/fans_page.dart';
import '../features/livestreaming/live_streaming_view.dart';
import '../features/profile/buytoken/buy_token_model.dart';
import '../features/profile/buytoken/buy_token_page.dart';
import '../features/profile/mywallet/my_wallet.dart';
import '../features/profile/mywallet/my_wallet_model.dart';



abstract class IRouter {
  //=
  Route<dynamic> generateRoute(RouteSettings settings);

  List<Route<dynamic>> generateInitialRoutes(String initialRouteName);
}

class RouteManager {
  static IRouter router = AppRouter();

  static List<Route> generateInitialRoutes(String initialRouteName) {
    return router.generateInitialRoutes(initialRouteName);
  }

  static Route generateRoute(RouteSettings settings) {
    return router.generateRoute(settings);
  }
}

Route routeOf(RouteSettings settings, {required Widget child}) {
  return PageTransition(
    child: child,
    settings: settings,
    type: PageTransitionType.rightToLeft,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 200),
  );
}

class AppRouter extends IRouter {
  //=

  @override
  Route generateRoute(RouteSettings settings) {
    //=
    switch (settings.name) {
      //=

      case Routes.addBillingDetails:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => AddEditBillingDetailsModel(),
              child: const AddEditBillingDetailsPage(),
            ));

      case Routes.album:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => AlbumModel(args: settings.arguments as AlbumArgs),
              child: const AlbumPage(),
            ));

      case Routes.albumArtists:
        final args = settings.arguments as AlbumArtistsArgs;
        return routeOf(settings, child: AlbumArtistsPage(args: args));

      case Routes.albums:
        final args = settings.arguments as AlbumsListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => AlbumsModel(args: args),
              child: const AlbumsPage(),
            ));

      case Routes.artist:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ArtistModel(args: settings.arguments as ArtistPageArgs),
              child: const ArtistPage(),
            ));

      case Routes.artistFollowers:
        final arguments = settings.arguments as ArtistFollowersPageArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<FollowersModel>(
              create: (_) => ArtistFollowersModel(args: arguments),
              child: const ArtistFollowersPage(),
            ));

      case Routes.artistFollowings:
        final arguments = settings.arguments as ArtistFollowingsPageArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<FollowingsModel>(
              create: (_) => ArtistFollowingsModel(args: arguments),
              child: const ArtistFollowingsPage(),
            ));

      case Routes.artists:
        final args = settings.arguments as ArtistListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ArtistsModel(args: args),
              child: const ArtistsPage(),
            ));

      case Routes.authSignIn:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => SignInModel(),
              child: const SignInPage(),
            ));

      case Routes.authSignUp:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => SignUpModel(),
              child: const SignUpPage(),
            ));

      case Routes.authSignUpEmailVerification:
        return routeOf(settings,
            child: ChangeNotifierProvider<EmailVerificationModel>(
              create: (_) => EmailSignUpVerificationModel(
                  args: settings.arguments as EmailSignUpVerificationArgs),
              child: const EmailSignUpVerificationPage(),
            ));

      case Routes.authSignUpPhoneVerification:
        return routeOf(settings,
            child: ChangeNotifierProvider<PhoneOtpVerificationModel>(
              create: (_) => PhoneSignUpVerificationModel(
                  args: settings.arguments as PhoneSignUpVerificationArgs),
              child: const PhoneSignUpVerificationPage(),
            ));

      case Routes.billingDetails:
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => BillingDetailsModel(),
                child: const BillingDetailsPage()));

      case Routes.blockedUsers:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => BlockedUsersModel(),
              child: const BlockedUsersPage(),
            ));

      case Routes.changePassword:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ChangePasswordModel(),
              child: const ChangePasswordPage(),
            ));

      case Routes.createOrEditPlaylist:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => CreateEditPlaylistModel(
                  args: settings.arguments as CreateEditPlaylistArgs?),
              child: const CreateEditPlaylistPage(),
            ));

      case Routes.dashboard:
        return routeOf(settings, child: const DashboardPage());

      case Routes.downloads:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => DownloadsModel(),
              child: const DownloadsPage(),
            ));

      case Routes.editBillingDetails:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => AddEditBillingDetailsModel(
                  args: settings.arguments as EditBillingDetailsArgs),
              child: const AddEditBillingDetailsPage(),
            ));

      case Routes.editProfile:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => EditProfileModel(),
              child: const EditProfilePage(),
            ));

      case Routes.feedback:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => FeedbackModel(),
              child: const FeedbackPage(),
            ));

      case Routes.findFriends:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => FindFriendsModel(),
              child: const FindFriendsPage(),
            ));

      case Routes.help:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ContactModel(),
              child: const ContactPage(),
            ));

      case Routes.liveShowCountdown:
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => LiveShowCountdownModel(
                    args: settings.arguments as LiveShowCountdownArgs),
                child: const LiveShowCountdownPage()));

      case Routes.onboarding:
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => OnboardingModel(),
                child: const OnboardingPage()));

      case Routes.onboardingGenreSelection:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => OnboardingGenreSelectionModel(),
              child: const OnboardingGenreSelectionPage(),
            ));

      case Routes.manageSubscription:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ManageSubscriptionModel(),
              child: const ManageSubscriptionPage(),
            ));

      case Routes.managePlaylistCollaborators:
        final args = settings.arguments as ManagePlaylistCollaboratorsArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ManagePlaylistCollaboratorsModel(args: args),
              child: const ManagePlaylistCollaboratorsPage(),
            ));

      case Routes.musicBrowseKindOptions:
        final args = settings.arguments as MusicBrowseKindOptionsArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => MusicBrowseKindOptionsModel(args: args),
              child: const MusicBrowseKindOptionsPage(),
            ));

      case Routes.musicBrowseKinds:
        final args = settings.arguments as MusicBrowseKindsArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => MusicBrowseKindsModel(args: args),
              child: const MusicBrowseKindsPage(),
            ));

      case Routes.musicBrowser:
        final args = settings.arguments as MusicBrowserArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => MusicBrowserModel(args: args),
              child: const MusicBrowserPage(),
            ));

      case Routes.notifications:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => NotificationsModel(),
              child: const NotificationsPage(),
            ));

      case Routes.paymentHistory:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PaymentHistoryModel(),
              child: const PaymentHistoryPage(),
            ));

      case Routes.phoneVerification:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PhoneVerificationModel(
                args: settings.arguments as PhoneVerificationArgs,
              ),
              child: const PhoneVerificationPage(),
            ));

      case Routes.playlist:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) =>
                  PlaylistModel(args: settings.arguments as PlaylistArgs),
              child: const PlaylistPage(),
            ));

      case Routes.playlistAddTracks:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PlaylistAddTracksModel(
                  args: settings.arguments as PlaylistAddTracksArgs),
              child: const PlaylistAddTracksPage(),
            ));

      case Routes.playlistCollaborationInvitation:
        final args = settings.arguments as PlaylistCollaborationInvitationArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PlaylistCollaborationInvitationModel(args: args),
              child: const PlaylistCollaborationInvitationPage(),
            ));

      case Routes.playlists:
        final args = settings.arguments as PlaylistsArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PlaylistsModel(args: args),
              child: const PlaylistsPage(),
            ));

      case Routes.playlistTracks:
        final args = settings.arguments as PlaylistTracksArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PlaylistTracksModel(args: args),
              child: const PlaylistTracksPage(),
            ));

      case Routes.podcast:
        final arguments = settings.arguments as PodcastDetailArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PodcastDetailModel(args: arguments),
              child: const PodcastDetailPage(),
            ));

      case Routes.podcastCategories:
        final arguments = settings.arguments as PodcastCategoryListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PodcastCategoriesModel(args: arguments),
              child: const PodcastCategoriesPage(),
            ));

      case Routes.podcastEpisode:
        final arguments = settings.arguments as PodcastEpisodeDetailArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PodcastEpisodeDetailModel(args: arguments),
              child: const PodcastEpisodeDetailPage(),
            ));

      case Routes.podcastEpisodes:
        final arguments = settings.arguments as PodcastEpisodeListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PodcastEpisodesModel(args: arguments),
              child: const PodcastEpisodesPage(),
            ));

      case Routes.podcasts:
        final arguments = settings.arguments as PodcastListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => PodcastsModel(args: arguments),
              child: const PodcastsPage(),
            ));

      case Routes.profileEmailVerification:
        return routeOf(settings,
            child: ChangeNotifierProvider<EmailVerificationModel>(
              create: (_) => ProfileEmailVerificationModel(
                args: settings.arguments as ProfileEmailVerificationArgs,
              ),
              child: const ProfileEmailVerificationPage(),
            ));

      case Routes.profilePhoneVerification:
        return routeOf(settings,
            child: ChangeNotifierProvider<PhoneOtpVerificationModel>(
              create: (_) => ProfilePhoneVerificationModel(
                args: settings.arguments as ProfilePhoneVerificationArgs,
              ),
              child: const ProfilePhoneVerificationPage(),
            ));

      case Routes.requestAccountRecovery:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => RequestAccountRecoveryModel(),
              child: const RequestAccountRecoveryPage(),
            ));

      case Routes.radioStations:
        final arguments = settings.arguments as RadioStationListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => RadioStationsModel(args: arguments),
              child: const RadioStationsPage(),
            ));

      case Routes.reportContent:
        final arguments = settings.arguments as ReportContentArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ReportContentModel(args: arguments),
              child: const ReportContentPage(),
            ));

      case Routes.search:
        final args = settings.arguments as SearchArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => SearchModel(args: args),
                child: const SearchPage()));

      case Routes.setPassword:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => SetPasswordModel(
                args: settings.arguments as SetPasswordArgs,
              ),
              child: const SetPasswordPage(),
            ));

      case Routes.shows:
        final args = settings.arguments as ShowListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ShowsModel(args: args),
              child: const ShowsPage(),
            ));

      case Routes.skits:
        final args = settings.arguments as SkitListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => SkitsModel(args: args),
              child: const SkitsPage(),
            ));

      case Routes.subscriptionPlanPayment:
        final args = settings.arguments as SubscriptionPaymentArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => SubscriptionPaymentModel(args: args),
                child: const SubscriptionPaymentPage()));

      case Routes.subscriptionPlanPaymentConfirmation:
        final args = settings.arguments as SubscriptionPaymentConfirmationArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) => SubscriptionPaymentConfirmationModel(args: args),
                child: const SubscriptionPaymentConfirmationPage()));

      case Routes.subscriptionPlanPurchaseProcess:
        final args = settings.arguments as SubscriptionPlanPurchaseProcessArgs;
        return routeOf(settings,
            child: MultiProvider(providers: [
              ChangeNotifierProvider(create: (_) => SubscriptionPlanPurchaseProcessModel(args: args)),
              ChangeNotifierProvider(create: (_) => BillingDetailsModel()),
              ChangeNotifierProvider(create: (_) => SubscriptionPaymentMethodsModel()),
            ], child: const SubscriptionPlanPurchaseProcessPage()));

      case Routes.subscriptionPlanSelectionPreview:
        final args = settings.arguments as SubscriptionPlanSelectionPreviewArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
                create: (_) =>
                    SubscriptionPlanSelectionPreviewModel(args: args, planName: args.planName),
                child:  SubscriptionPlanSelectionPreviewPage()));

      case Routes.trackArtists:
        final args = settings.arguments as TrackArtistsArgs;
        return routeOf(settings, child: TrackArtistsPage(args: args));

      case Routes.tracks:
        final args = settings.arguments as TrackListArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => TracksModel(args: args),
              child: const TracksPage(),
            ));

      case Routes.userFollowers:
        final arguments = settings.arguments as UserFollowersPageArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<FollowersModel>(
              create: (_) => UserFollowersModel(args: arguments),
              child: const UserFollowersPage(),
            ));

      case Routes.userFollowings:
        final arguments = settings.arguments as UserFollowingsPageArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<FollowingsModel>(
              create: (_) => UserFollowingsModel(args: arguments),
              child: const UserFollowingsPage(),
            ));

      case Routes.userProfile:
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) =>
                  UserProfileModel(args: settings.arguments as UserProfileArgs),
              child: const UserProfilePage(),
            ));

      case Routes.usersActivities:
        final args = settings.arguments as UsersActivitiesArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => UsersActivitiesModel(args: args),
              child: const UsersActivitiesPage(),
            ));
      case Routes.eventMeetView:
        final args = settings.arguments as EventMeetView;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => EventMeetModel(),
              child:  EventMeetView(artistId: args.artistId,),
            ));
      case Routes.exclusiveContentView:
      // final args = settings.arguments as UsersActivitiesArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider(
              create: (_) => ExclusiveContentViewModel(),
              child: const ExclusiveContentView(),
            ));

      case Routes.fansViewPage:
        final args = settings.arguments as FansPageView;
        return routeOf(settings,
            child: ChangeNotifierProvider<FansModel>(
              create: (_) => FansModel(),
              child:   FansPageView(artistId: args.artistId, artistName: args.artistName,),
            ));

      case Routes.activeDiscountsView:
        final args = settings.arguments as ActiveDiscountsView;
        return routeOf(settings,
            child: ChangeNotifierProvider<ActiveDiscountsModel>(
              create: (_) => ActiveDiscountsModel(),
              child:    ActiveDiscountsView(artistId: args.artistId,),
            ));
      case Routes.myWalletPage:
      //  final args = settings.arguments as ActiveDiscountsView;
        return routeOf(settings,
            child: ChangeNotifierProvider<MyWalletModel>(
              create: (_) => MyWalletModel(),
              child:    const MyWalletPage(),
            ));
      case Routes.artistTipPage:
        final args = settings.arguments as ArtistTipArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<ArtistTipModel>(
              create: (_) => ArtistTipModel(artist: args.artist, haveToken: args.haveToken),
              child:    const ArtistTipPage(),
            ));
      case Routes.buyTokenPage:
      // final args = settings.arguments as ArtistTipArgs;
        return routeOf(settings,
            child: ChangeNotifierProvider<BuyTokenModel>(
              create: (_) => BuyTokenModel(),
              child:    const BuyTokenPage(),
            ));

      case Routes.liveStreaming:
       final args = settings.arguments as LiveStreamingView;
        return routeOf(settings,
            child:  LiveStreamingView(showTitle: args.showTitle, artistImage: args.artistImage, channelName: args.channelName, serverUrl: args.serverUrl, rtcToken: args.rtcToken,));

      case Routes.liveShowView:
       final args = settings.arguments as LiveShowView;
        return routeOf(settings,
            child: ChangeNotifierProvider<LiveShowModel>(
              create: (_) => LiveShowModel(),
              child:     LiveShowView(artistId: args.artistId),
            ));

      default:
        return routeOf(settings,
            child: UnknownRouteWidget(routeName: settings.name));
    }
  }

  @override
  List<Route> generateInitialRoutes(String initialRouteName) {
    //=
    final settings = RouteSettings(name: initialRouteName);
    return [generateRoute(settings)];
  }
}

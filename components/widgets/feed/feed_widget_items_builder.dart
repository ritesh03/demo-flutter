
import 'dart:math';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/artist_discounts.dart';
import 'package:kwotdata/models/artist/merchandising.dart';
import 'package:kwotdata/models/artist/upcoming.events.dart';
import 'package:kwotdata/models/liveshows/live_shows.dart';
import 'package:kwotdata/models/photos/photos.dart';
import 'package:kwotdata/models/songs/song.dart';
import 'package:kwotdata/models/videos/video.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/empty_indicator.widget.dart';
import 'package:kwotmusic/features/activity/widget/user_activity_list_item.widget.dart';
import 'package:kwotmusic/features/album/widget/album_grid_item.widget.dart';
import 'package:kwotmusic/features/album/widget/album_list_item.widget.dart';
import 'package:kwotmusic/features/album/widget/numbered_album_list_item.widget.dart';
import 'package:kwotmusic/features/album/widget/trending_album_grid_item.widget.dart';
import 'package:kwotmusic/features/artist/widget/artist_grid_item.widget.dart';
import 'package:kwotmusic/features/artist/widget/artist_list_item.widget.dart';
import 'package:kwotmusic/features/music/browsekind/widget/music_browse_kind_grid_item.widget.dart';
import 'package:kwotmusic/features/music/browsekind/widget/music_browse_kind_list_item.widget.dart';
import 'package:kwotmusic/features/music/browsekindoptions/widget/music_browse_kind_option_grid_item.widget.dart';
import 'package:kwotmusic/features/music/browsekindoptions/widget/music_browse_kind_option_list_item.widget.dart';
import 'package:kwotmusic/features/playlist/widget/curated_playlist_grid_item.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_grid_item.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_list_item.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_paged_grid_item.widget.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_grid_item.widget.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_list_item.widget.dart';
import 'package:kwotmusic/features/podcastcategory/widget/podcast_category_grid_item.widget.dart';
import 'package:kwotmusic/features/podcastcategory/widget/podcast_category_list_item.widget.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_grid_item.widget.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_list_item.widget.dart';
import 'package:kwotmusic/features/radiostation/widget/radio_station_grid_item.widget.dart';
import 'package:kwotmusic/features/radiostation/widget/radio_station_list_item.widget.dart';
import 'package:kwotmusic/features/show/widget/live_show_grid_item.widget.dart';
import 'package:kwotmusic/features/show/widget/show_grid_item.widget.dart';
import 'package:kwotmusic/features/show/widget/upcoming_show_list_item.widget.dart';
import 'package:kwotmusic/features/skit/widget/skit_grid_item.widget.dart';
import 'package:kwotmusic/features/skit/widget/skit_list_item.widget.dart';
import 'package:kwotmusic/features/track/widget/track_grid_item.widget.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import '../../../features/artist/fanclubviews/active_discount_widget.dart';
import '../../../features/artist/fanclubviews/event_list_item_widget.dart';
import '../../../features/artist/fanclubviews/live_shows_widget.dart';
import '../../../features/artist/fanclubviews/merchandise_widget.dart';
import '../../../features/artist/fanclubviews/photos_widget.dart';
import '../../../features/artist/fanclubviews/song_widget.dart';
import '../../../features/artist/fanclubviews/videos_widget.dart';
import 'feed_fixed_items_grid.widget.dart';
import 'feed_horizontal_item_list.widget.dart';
import 'feed_routing.dart';
import 'feed_vertical_item_list.widget.dart';
import 'feed_vertically_grouped_horizontal_page_list.widget.dart';

/// TODO: Add default items per specialization and structure
class FeedWidgetItemsBuilder {
  static FeedWidgetItemsBuilder instance = FeedWidgetItemsBuilder();

  FeedWidgetItemsBuilder();

  Widget buildItemList({
    required BuildContext context,
    required Feed feed,
    double itemSpacing = 0,
    FeedRouting? routing,
  }) {
    if (feed.items.isEmpty) {
      return const EmptyIndicator();
    }


    Widget widgetBuilder(BuildContext context, int index) {

      return _buildItemWidget(
        context: context,
        feed: feed,
        index: index,
        routing: routing,
      );
    }

    switch (feed.structure) {
      case FeedStructure.listItemNx1:
        return FeedVerticalItemList(
            itemCount: feed.items.length,
            itemSpacing: itemSpacing,
            padding: EdgeInsets.symmetric(horizontal: itemSpacing),
            widgetBuilder: widgetBuilder);

      case FeedStructure.gridItem1xN:
        return FeedHorizontalItemList(
            itemCount: feed.items.length,
            itemSpacing: itemSpacing,
            widgetBuilder: widgetBuilder);

      case FeedStructure.gridItem2x2:
        return FeedFixedItemsGrid(
            itemCount: min(feed.items.length, 4),
            columnCount: 2,
            itemSpacing: itemSpacing,
            widgetBuilder: widgetBuilder);

      case FeedStructure.pagedListItem4xN:
        // Uses ListView
        // return FeedVerticallyGroupedHorizontalItemList(
        //     itemCount: feed.items.length,
        //     itemSpacing: itemSpacing,
        //     widgetBuilder: widgetBuilder);
        //
        // Uses PageView
        return FeedVerticallyGroupedHorizontalPageList(
            itemCount: feed.items.length,
            itemSpacing: itemSpacing,
            itemsPerGroup: 4,
            widgetBuilder: widgetBuilder);

      case FeedStructure.pagedGridItem1xN:
      case FeedStructure.pagedListItem1xN:
        return FeedVerticallyGroupedHorizontalPageList(
            itemCount: feed.items.length,
            itemSpacing: itemSpacing,
            itemsPerGroup: 1,
            widgetBuilder: widgetBuilder);
    }
  }

  Widget _buildItemWidget({
    required BuildContext context,
    required Feed feed,
    required int index,
    FeedRouting? routing,
  }) {
    final feedRouting = routing ?? locator<FeedRouting>();
    switch (feed.type) {
      /// ALBUM
      case FeedType.album:
        return _buildAlbumWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            index: index,
            album: feed.items[index] as Album,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// ARTIST + MUSICIAN
      case FeedType.artist:
      case FeedType.musician:
        return _buildArtistWidget(
            context: context,
            feedStructure: feed.structure,
            artist: feed.items[index] as Artist,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// MUSIC > BROWSE BY
      case FeedType.musicBrowseKind:
        return _buildMusicBrowseKindWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            kind: feed.items[index] as MusicBrowseKind,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// MUSIC > BROWSE BY Kind > Option
      case FeedType.musicBrowseKindOption:
        return _buildMusicBrowseKindOptionWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            browseKindOption: feed.items[index] as MusicBrowseKindOption,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// PLAYLIST
      case FeedType.playlist:
        return _buildPlaylistWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            playlist: feed.items[index] as Playlist,
            onPlaylistTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// PODCAST
      case FeedType.podcast:
        return _buildPodcastWidget(
            context: context,
            feedStructure: feed.structure,
            podcast: feed.items[index] as Podcast,
            onPodcastTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// PODCAST CATEGORY
      case FeedType.podcastCategory:
        return _buildPodcastCategoryWidget(
            context: context,
            feedStructure: feed.structure,
            podcastIndex: index,
            podcastCategory: feed.items[index] as PodcastCategory,
            onPodcastCategoryTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// PODCAST EPISODE
      case FeedType.podcastEpisode:
        return _buildPodcastEpisodeWidget(
            context: context,
            feedStructure: feed.structure,
            podcastEpisode: feed.items[index] as PodcastEpisode,
            onPodcastEpisodeTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// RADIO STATION
      case FeedType.radioStation:
        return _buildRadioStationWidget(
            context: context,
            feedStructure: feed.structure,
            radioStation: feed.items[index] as RadioStation,
            onRadioStationTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// SHOW
      case FeedType.show:
        /// This is the live show in fan club feedType should be changed with live_shows
      return  _buildShowWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            show: feed.items[index] as Show,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// SKIT
      case FeedType.skit:
        return _buildSkitWidget(
            context: context,
            feedStructure: feed.structure,
            skit: feed.items[index] as Skit,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// TRACK
      case FeedType.track:
        return _buildTrackWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            track: feed.items[index] as Track,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });

      /// USER ACTIVITY
      case FeedType.userActivity:
        return _buildUserActivityWidget(
            context: context,
            feedStructure: feed.structure,
            feedSpecialization: feed.specialization,
            activity: feed.items[index] as UserActivity,
            onTap: (item) {
              return feedRouting.handleItemTap(context, feed: feed, item: item);
            });
      ///UPCOMING EVENTS
      case FeedType.upcomingEvents:
        return EventListItemWidget(
          artistId: feed.id.replaceAll("artist_id:", ""),
          artistName: "",
          events: feed.items[index] as UpcomingEvents,
        );

      ///MERCHANDISING
      case FeedType.merchandising:
        return MerchandiseWidget(
          merchandise: feed.items[index] as Merchandising,
        );

      ///DISCOUNT
      case FeedType.discount:
        return ActiveDiscountWidget(
          discounts: feed.items[index] as ActiveDiscounts,
        );
        ///EXCLUSIVE CONTENT PHOTOS
      case FeedType.photos:
        Photos p = feed.items[index] as Photos;
        return PhotosWidget(
          photoUrl: p.image,
        );
        ///EXCLUSIVE CONTENT SONGS
      case FeedType.songs:
        Song songOb = feed.items[index] as Song;
        return SongListWidget(
          songType: songOb.type,
          title: songOb.title,
          songImage: songOb.image,
          isFromFeed: true,
          id: songOb.id,
          url: songOb.url,
        );
        ///EXCLUSIVE CONTENT VIDEOS
      case FeedType.videos:
        Videos videoOb = feed.items[index] as Videos;
        return VideosWidget(
          views: videoOb.views,
          title: videoOb.title,
          image: videoOb.image,
          duration: videoOb.duration,
          addedAt: videoOb.addedAt,
          isFromFeed: true,
          id: videoOb.id,
          url: videoOb.url,

        );

      case FeedType.fanConnect:
        return LiveShowsWidget(
          artistId:  feed.id.replaceAll("artist_id:", ""),
          show: feed.items[index] as LiveShow,
        );

      /// UNKNOWN
      default:
        return _buildUnknownWidget(context, feedStructure: feed.structure);
    }
  }

  Widget _buildAlbumWidget({
    required BuildContext context,
    required FeedStructure feedStructure,
    required String? feedSpecialization,
    required int index,
    required Album album,
    required Function(Album album) onTap,
  }) {
    switch (feedStructure) {
      case FeedStructure.listItemNx1:
        switch (feedSpecialization) {
          case AlbumSpecialization.numbered:
            return NumberedAlbumListItem(
              index: index,
              album: album,
              onTap: () => onTap(album),
            );
          default:
            return AlbumListItem(album: album, onTap: onTap);
        }

      case FeedStructure.gridItem1xN:
      case FeedStructure.gridItem2x2:
        switch (feedSpecialization) {
          case AlbumSpecialization.trending:
            return TrendingAlbumGridItem(
              width: 152.r,
              album: album,
              onTap: onTap,
            );
          default:
            return AlbumGridItem(width: 152.r, album: album, onTap: onTap);
        }

      case FeedStructure.pagedListItem4xN:
      case FeedStructure.pagedListItem1xN:
        return const _UnknownFeedItem.listItem();

      case FeedStructure.pagedGridItem1xN:
        return const _UnknownFeedItem.pagedGridItem();
    }
  }
}

Widget _buildArtistWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required Artist artist,
  required Function(Artist artist) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return ArtistListItem(artist: artist, onTap: () => onTap(artist));

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return ArtistGridItem(
        width: 96.r,
        artist: artist,
        onTap: (artist) => onTap(artist),
      );

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildMusicBrowseKindWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required MusicBrowseKind kind,
  required Function(MusicBrowseKind) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return MusicBrowseKindListItem(
        kind: kind,
        onTap: () => onTap(kind),
      );

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return MusicBrowseKindGridItem(
        width: 128.r,
        kind: kind,
        onTap: () => onTap(kind),
      );

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildMusicBrowseKindOptionWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required MusicBrowseKindOption browseKindOption,
  required Function(MusicBrowseKindOption) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return MusicBrowseKindOptionListItem(
        option: browseKindOption,
        onTap: () => onTap(browseKindOption),
      );

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return MusicBrowseKindOptionGridItem(
        width: 128.r,
        option: browseKindOption,
        onTap: () => onTap(browseKindOption),
      );

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildPlaylistWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required Playlist playlist,
  required Function(Playlist playlist) onPlaylistTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return PlaylistListItem(
        playlist: playlist,
        onTap: () => onPlaylistTap(playlist),
      );

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      switch (feedSpecialization) {
        case PlaylistSpecialization.madeForYou:
          return CuratedPlaylistGridItem(
              width: 200.r, playlist: playlist, onTap: onPlaylistTap);
        default:
          return PlaylistGridItem(
            width: 128.r,
            playlist: playlist,
            onTap: () => onPlaylistTap(playlist),
          );
      }

    case FeedStructure.pagedGridItem1xN:
      return PlaylistPagedGridItem(playlist: playlist, onTap: onPlaylistTap);
  }
}

Widget _buildPodcastWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required Podcast podcast,
  required Function(Podcast podcast) onPodcastTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return PodcastListItem(podcast: podcast, onPodcastTap: onPodcastTap);

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return PodcastGridItem(
          width: 128.w, podcast: podcast, onPodcastTap: onPodcastTap);

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildPodcastCategoryWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required int podcastIndex,
  required PodcastCategory podcastCategory,
  required Function(PodcastCategory podcastCategory) onPodcastCategoryTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return PodcastCategoryListItem(
          category: podcastCategory, onTap: onPodcastCategoryTap);

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return PodcastCategoryGridItem(
          width: 128.w,
          index: podcastIndex,
          category: podcastCategory,
          onTap: onPodcastCategoryTap);

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildPodcastEpisodeWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required PodcastEpisode podcastEpisode,
  required Function(PodcastEpisode podcastEpisode) onPodcastEpisodeTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return PodcastEpisodeListItem(
          podcastEpisode: podcastEpisode,
          onPodcastEpisodeTap: onPodcastEpisodeTap);

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return PodcastEpisodeGridItem(
          width: 128.w,
          podcastEpisode: podcastEpisode,
          onPodcastEpisodeTap: onPodcastEpisodeTap);

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildRadioStationWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required RadioStation radioStation,
  required Function(RadioStation radioStation) onRadioStationTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return RadioStationListItem(
        radioStation: radioStation,
        onRadioStationTap: onRadioStationTap,
      );

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return RadioStationGridItem(
        width: 128.w,
        radioStation: radioStation,
        onRadioStationTap: onRadioStationTap,
      );

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildShowWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required Show show,
  required Function(Show show) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      switch (feedSpecialization) {
        case ShowSpecialization.upcoming:
          return UpcomingShowListItem(
            show: show,
            onTap: (show) => onTap(show),
          );
        default:
          return const _UnknownFeedItem.listItem();
      }

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      switch (feedSpecialization) {
        case ShowSpecialization.live:
          return LiveShowGridItem(
            width: 72.w,
            show: show,
            onTap: (show) => onTap(show),
          );
        default:
          return ShowGridItem(
            width: 148.w,
            show: show,
            onTap: (show) => onTap(show),
          );
      }

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildSkitWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required Skit skit,
  required Function(Skit skit) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return SkitListItem(skit: skit, onTap: onTap);

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return SkitGridItem(width: 148.w, skit: skit, onTap: onTap);

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildTrackWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required Track track,
  required Function(Track) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return TrackListItem(
          track: track,
          onTap: (track) {
            onTap(track);
            return true;
          });

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return TrackGridItem(
          width: 128.w,
          track: track,
          onTap: (track) {
            onTap(track);
            return true;
          });

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildUserActivityWidget({
  required BuildContext context,
  required FeedStructure feedStructure,
  required String? feedSpecialization,
  required UserActivity activity,
  required Function(UserActivity) onTap,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
      return UserActivityListItem(
        activity: activity,
        onTap: () => onTap(activity),
      );

    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return const _UnknownFeedItem.listItem();

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return const _UnknownFeedItem.gridItem();

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

Widget _buildUnknownWidget(
  BuildContext context, {
  required FeedStructure feedStructure,
}) {
  switch (feedStructure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return const _UnknownFeedItem.listItem();

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
      return const _UnknownFeedItem.gridItem();

    case FeedStructure.pagedGridItem1xN:
      return const _UnknownFeedItem.pagedGridItem();
  }
}

class _UnknownFeedItem extends StatelessWidget {
  const _UnknownFeedItem({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  const _UnknownFeedItem.listItem({Key? key})
      : width = null,
        height = 48,
        super(key: key);

  const _UnknownFeedItem.gridItem({Key? key})
      : width = 172,
        height = 172,
        super(key: key);

  const _UnknownFeedItem.pagedGridItem({Key? key})
      : width = 256,
        height = 256,
        super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DynamicTheme.get(context).black(),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
      child: Text("Unknown Item", style: TextStyles.heading4),
    );
  }
}

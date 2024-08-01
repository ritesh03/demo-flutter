import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';
import 'package:kwotmusic/features/playback/video/video_item.dart';

extension VideoItemTypeExt on VideoItemType {
  PhotoKind get photoKind {
    switch (this) {
      case VideoItemType.show:
        return PhotoKind.show;
      case VideoItemType.skit:
        return PhotoKind.skit;
      case VideoItemType.video:
        return PhotoKind.show;
    }
  }
}

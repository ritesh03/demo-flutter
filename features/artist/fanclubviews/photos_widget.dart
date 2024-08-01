import 'package:flutter/cupertino.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/kit/component_radius.dart';
import '../../../components/widgets/alert_box_buy_token.dart';
import '../../../components/widgets/photo/photo.dart';
/// This is a common widget used in feeds and exclusive content
class PhotosWidget extends StatelessWidget {
  String photoUrl;
  PhotosWidget({Key? key,required this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ScaleTap(
            onPressed: (){
              ShowAlertBox.showPhotosAlert(context, photoUrl);

            },
            child: _ArtistPhoto( photoUrl: photoUrl,)),
      ],
    );
  }
}
class _ArtistPhoto extends StatelessWidget {
  String? photoUrl;
   _ArtistPhoto({
    Key? key, this.photoUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Photo.track(
    photoUrl ?? "",
      options: PhotoOptions(
        width: 104.w,
          height: 104.h,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/merchandising.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_radius.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/photo/photo.dart';
import '../../../util/util_url_launcher.dart';

class MerchandiseWidget extends StatelessWidget {
  Merchandising  merchandise;
  MerchandiseWidget({Key? key,required this.merchandise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaleTap(
          onPressed: (){
            UrlLauncherUtil.openPageForProduct(context,merchandise.url);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140.h,
                width: 152.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ComponentRadius.normal.r)
                ),
                child: _buildPhotoView(merchandise),
              ),
              SizedBox(height: ComponentInset.small.h,),
              Text(merchandise.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldHeading5),
              Text(merchandise.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading6.copyWith(color: DynamicTheme.get(context).neutral10()))
            ],
          ),
        ),

      ],
    );
  }
}
Widget _buildPhotoView(Merchandising  merchandise){
  return Photo.skit(
    merchandise.image,
    options: PhotoOptions(
      height: 140.h,
      width: 152.w,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
    ),
  );

}


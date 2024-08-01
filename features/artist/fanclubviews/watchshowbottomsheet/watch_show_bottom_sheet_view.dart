import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/artist/get.artist.events.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import '../../../../components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import '../../../../components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/photo/photo.dart';
import '../../../../components/widgets/photo/svg_asset_photo.dart';


class WatchShowBottomSheet extends StatefulWidget {
  String image;
  String title;
  String tokens;
  String artistName;
  VoidCallback onTapWatch;
  WatchShowBottomSheet({Key? key,required this.onTapWatch,required this.title,required this.image,required this.artistName,required this.tokens}) : super(key: key);

  @override
  State<WatchShowBottomSheet> createState() => _WatchShowBottomSheetState();
}

class _WatchShowBottomSheetState extends State<WatchShowBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tileMargin = EdgeInsets.only(top: ComponentInset.small.h);
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: 272.h,
        color: DynamicTheme.get(context).neutral80(),
        child: Column(
          children: <Widget>[
            Center(
              child: BottomSheetDragHandle(
                margin: EdgeInsets.only(
                  top: ComponentInset.small.h,
                ),
              ),
            ),
            SizedBox(
              height: 22.h,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
              child: Column(
                children: <Widget>[
                  _BuildImageShowTitleWidget(tokens: widget.tokens, artistName: widget.artistName, image: widget.image, title: widget.title,),
                  SizedBox(
                    height: 12.h,
                  ),
                  const Center(
                    child: BottomSheetDragHandle(
                      width: double.maxFinite,
                    ),
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  BottomSheetTile(
                      iconPath: Assets.iconShare,
                      margin: tileMargin,
                      height: 48.h,
                      text: LocaleResources.of(context).share,
                      onTap: () {}),
                  SizedBox(
                    height: 16.h,
                  ),
                  Button(
                      text: LocaleResources.of(context).watchTheShow,
                      height: ComponentSize.large.h,
                      type: ButtonType.primary,
                      width: MediaQuery.of(context).size.width,
                      onPressed: widget.onTapWatch)
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

class _BuildImageShowTitleWidget extends StatelessWidget {
  String image;
  String title;
  String tokens;
  String artistName;
  _BuildImageShowTitleWidget({Key? key, required this.tokens,required this.artistName,required this.image,required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _BuildImage(image: image),
        SizedBox(
          width: 14.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _BuildTitle(title: title),
            _BuildArtistName(artistName: artistName),
            tokens == "0" ?Text(
              "FREE",
              maxLines: 1,
              style: TextStyles.boldHeading4
                  .copyWith(color: DynamicTheme.get(context).white()),
            ):_BuildTokenWidget(token: tokens),
          ],
        )
      ],
    );
  }
}

class _BuildImage extends StatelessWidget {
  String image;
  _BuildImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Photo.any(
      image,
      options: PhotoOptions(
          height: 72.r,
          width: 104.r,
          borderRadius: BorderRadius.circular(ComponentSize.small8.r)),
    );
  }
}

class _BuildTitle extends StatelessWidget {
  String title;
  _BuildTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading3
          .copyWith(color: DynamicTheme.get(context).white()),
    );
  }
}

class _BuildArtistName extends StatelessWidget {
  String artistName;
  _BuildArtistName({Key? key, required this.artistName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      artistName,
      maxLines: 1,
      style: TextStyles.heading4
          .copyWith(color: DynamicTheme.get(context).neutral10()),
    );
  }
}

class _BuildTokenWidget extends StatelessWidget {
  String token;
  _BuildTokenWidget({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("This is the token :::$token");
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgAssetPhoto(
          Assets.iconTokens,
          width: 13.w,
          height: 12.h,
        ),
        SizedBox(
          width: 3.w,
        ),
        Text(
          token == "null"?"0":token,
          maxLines: 1,
          style: TextStyles.boldHeading4
              .copyWith(color: DynamicTheme.get(context).white()),
        ),
      ],
    );
  }
}

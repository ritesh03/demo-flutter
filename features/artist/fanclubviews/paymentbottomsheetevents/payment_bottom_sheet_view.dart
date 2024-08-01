import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/artist/get.artist.events.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import '../../../../components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/photo/photo.dart';
import '../../../../components/widgets/photo/svg_asset_photo.dart';
import '../watchshowbottomsheet/open_watch_show_bottom_sheet.dart';

class PaymentBottomSheetView extends StatefulWidget {
  String image;
  String title;
  String tokens;
  String artistName;
  VoidCallback onTapPayment;
  PaymentBottomSheetView({
    Key? key,required this.onTapPayment,required this.title,required this.image,required this.tokens,required this.artistName
  }) : super(key: key);

  @override
  State<PaymentBottomSheetView> createState() =>
      _PaymentBottomSheetViewState();
}

class _PaymentBottomSheetViewState extends State<PaymentBottomSheetView> {


  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return  Container(
              height: 336.h,
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
                  SizedBox(height: 22.h,),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                    child: Column(
                      children: <Widget>[
                        _BuildImageShowTitleWidget(image: widget.image, artistName: widget.artistName, tokens: widget.tokens, title: widget.title,),
                        SizedBox(height: 14.h,),
                        Center(
                          child: BottomSheetDragHandle(
                            width: double.maxFinite,
                            margin: EdgeInsets.only(
                                top: ComponentInset.small.h,
                                bottom: ComponentInset.small.h),
                          ),
                        ),
                        SizedBox(height: 24.h,),
                        _BuildHeading(heading: LocaleResources.of(context).startWatchingTheShow),
                        SizedBox(height: 8.h,),
                        _BuildSubHeading(subHeading:LocaleResources.of(context).evenIfTheShowHGasAlreadyStarted),
                        SizedBox(height: 16.h,),
                        Button(
                            text: LocaleResources.of(context).proceedToPayment,
                            height: ComponentSize.large.h,
                            type: ButtonType.primary,
                            width: MediaQuery.of(context).size.width,
                            onPressed: widget.onTapPayment,)

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
   _BuildImageShowTitleWidget({Key? key,required this.image,required this.artistName,required this.tokens,required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:<Widget> [
    _BuildImage(image: image),
        SizedBox(width: 14.w,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:<Widget> [
            _BuildTitle(title: title),
            _BuildArtistName(artistName: artistName),
           tokens != "0" &&tokens != "null"? _BuildTokenWidget(token:tokens):Container(),
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
        borderRadius: BorderRadius.circular(ComponentSize.small8.r)
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgAssetPhoto(Assets.iconTokens, width: 13.w, height: 12.h, ),
        SizedBox(width: 3.w,),
        Text(
          token,
          maxLines: 1,
          style: TextStyles.boldHeading4
              .copyWith(color: DynamicTheme.get(context).white()),
        ),
      ],
    );
  }
}

class _BuildHeading extends StatelessWidget {
  String heading;
  _BuildHeading({Key? key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      heading,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyles.boldHeading2
          .copyWith(color: DynamicTheme.get(context).white()),
    );
  }
}

class _BuildSubHeading extends StatelessWidget {
  String subHeading;
  _BuildSubHeading({Key? key, required this.subHeading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      subHeading,
      textAlign: TextAlign.center,
      style: TextStyles.heading5
          .copyWith(color: DynamicTheme.get(context).neutral10()),
    );
  }
}





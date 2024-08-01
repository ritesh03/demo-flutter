import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/artist/get.artist.events.dart';

import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/features/artist/fanclubviews/paymentbottomsheetevents/payment_bottom_sheet_view.dart';

class OpenPaymentBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(
    BuildContext context,
      {required VoidCallback onTapPayment,required String image,
      required String title,
      required String tokens,
      required String artistName}
  ) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => OpenPaymentBottomSheet( onTapPayment:  onTapPayment, image: image, title: title, tokens: tokens, artistName: artistName,),
    );
  }

  OpenPaymentBottomSheet({Key? key,required this.image,required this.onTapPayment,required this.title,required this.tokens,required this.artistName}) : super(key: key);
  String image;
  String title;
  String tokens;
  String artistName;
   VoidCallback onTapPayment;
  @override
  State<OpenPaymentBottomSheet> createState() => _OpenPaymentBottomSheetState();
}

class _OpenPaymentBottomSheetState extends State<OpenPaymentBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return PaymentBottomSheetView( onTapPayment: widget.onTapPayment, title: widget.title, image: widget.image, tokens: widget.tokens, artistName: widget.artistName,);
  }
}

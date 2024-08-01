import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class RadioStationLikeUpdatedEvent extends Event {
  RadioStationLikeUpdatedEvent({
    required this.id,
    required this.liked,
    required this.likes,
  }) : super(id: id);

  final String id;
  final bool liked;
  final int likes;

  RadioStation update(RadioStation radioStation) {
    if (radioStation.id != id) return radioStation;
    return radioStation.copyWith(liked: liked, likes: likes);
  }
}

import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class ProfileUpdatedEvent extends Event {
  final Profile profile;

  ProfileUpdatedEvent(this.profile) : super(id: profile.id);

  Profile update(Profile profile) {
    if (profile.id != this.profile.id) return profile;

    /// just replace the profile-instance for now
    return this.profile;
  }
}

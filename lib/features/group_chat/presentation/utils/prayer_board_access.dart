import 'package:flutter_pecha/features/group_profile/domain/entities/group_event.dart';
import 'package:flutter_pecha/features/group_profile/presentation/utils/group_event_live_utils.dart';

/// Whether a prayer board still takes new requests at [now]. Praying for the
/// requests already there stays open either way (#1098).
///
/// [event] is null for a space, which has no end, and while the event is
/// still loading: the board stays open then, since a failed fetch must not
/// lock it. A recurring event stays open here too: the app only knows its
/// next occurrence, so the backend decides when the series is over and
/// refuses with EVENT_ENDED.
bool prayerBoardTakesRequests({
  required GroupEvent? event,
  required DateTime now,
}) {
  if (event == null) return true;
  return !GroupEventLiveUtils.hasEnded(event, now);
}

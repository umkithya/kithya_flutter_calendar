import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../calendar_event.dart';
import 'days_row.dart';

/// Numbers to return accurate events in the cell.
const dayLabelContentHeight = 16;
const dayLabelVerticalMargin = 4;
const _dayLabelHeight = dayLabelContentHeight + (dayLabelVerticalMargin * 2);

const _eventLabelContentHeight = 18;
const _eventLabelBottomMargin = 3;
const _eventLabelHeight = _eventLabelContentHeight + _eventLabelBottomMargin;

/// Get events to be shown from [CalendarStateController]
///
/// Shows accurate number of [_EventLabel] by the height of the parent cell
class EventLabels extends HookConsumerWidget {
  const EventLabels({
    super.key,
    required this.date,
    required this.events,
  });

  final DateTime date;
  final List<CalendarEvent> events;

  List<CalendarEvent> _eventsOnTheDay(
      DateTime date, List<CalendarEvent> events) {
    final res = events
        .where((event) =>
            event.eventDate.year == date.year &&
            event.eventDate.month == date.month &&
            event.eventDate.day == date.day)
        .toList();
    return res;
  }

  bool _hasEnoughSpace(double cellHeight, int eventsLength) {
    debugPrint("cellHeight: $cellHeight");
    debugPrint("cellHeight: $cellHeight");
    final eventsTotalHeight = (_eventLabelHeight) * eventsLength;
    final spaceForEvents = cellHeight - _dayLabelHeight;
    return spaceForEvents > eventsTotalHeight;
  }

  int _maxIndex(double cellHeight, int eventsLength) {
    final spaceForEvents = cellHeight - (_dayLabelHeight + 10);
    const indexing = 1;
    const indexForPlot = 1;
    return spaceForEvents ~/ _eventLabelHeight - (indexing + indexForPlot);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellHeight = ref.watch(cellHeightProvider);
    if (cellHeight == null) {
      return const SizedBox.shrink();
    }
    final eventsOnTheDay = _eventsOnTheDay(date, events);
    final hasEnoughSpace = _hasEnoughSpace(cellHeight, eventsOnTheDay.length);
    final maxIndex = _maxIndex(cellHeight, eventsOnTheDay.length);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: eventsOnTheDay.length,
      itemBuilder: (context, index) {
        if (hasEnoughSpace) {
          return _EventLabel(eventsOnTheDay[index]);
        } else if (index < maxIndex) {
          return _EventLabel(eventsOnTheDay[index]);
        } else if (index == maxIndex) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EventLabel(
                eventsOnTheDay[index],
              ),
              Center(
                child: Text(
                  "+${eventsOnTheDay.length}",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
              // const Icon(
              //   Icons.more_horiz,
              //   size: 13,
              // )
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// label to show [CalendarEvent]
class _EventLabel extends StatelessWidget {
  const _EventLabel(this.event);

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 3),
      height: 18,
      decoration: BoxDecoration(
          color: event.eventBackgroundColor,
          borderRadius: BorderRadius.circular(2)),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(
            event.eventName,
            style: event.eventTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

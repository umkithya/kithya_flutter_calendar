import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kithya_flutter_calendar/kithya_flutter_calendar.dart';

import 'event_labels.dart';
import 'measure_size.dart';

final dataRowKeyState = GlobalKey<DaysRowState>();
final cellHeightProvider = StateProvider<double?>((ref) => null);
final selectIndexProvider = StateProvider<String>((ref) => "");

/// Show the row of [_DayCell] cells with events
class DaysRow extends StatefulWidget {
  const DaysRow({
    Key? key,
    required this.visiblePageDate,
    required this.dates,
    required this.dateTextStyle,
    required this.onCellTapped,
    required this.todayMarkColor,
    required this.todayTextColor,
    required this.events,
    this.weekProperty,
    required this.rowIndex,
  }) : super(key: key);

  final List<DateTime> dates;
  final DateTime visiblePageDate;
  final TextStyle? dateTextStyle;
  final Future<bool?> Function(DateTime)? onCellTapped;
  final Color todayMarkColor;
  final Color todayTextColor;
  final List<CalendarEvent> events;
  final WeekProperty? weekProperty;
  final int rowIndex;

  @override
  State<DaysRow> createState() => DaysRowState();
}

class DaysRowState extends State<DaysRow> {
  double? cellHeight;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: widget.dates.asMap().entries.map((e) {
          return DayCell(
            cellIndex: e.key,
            rowIndex: widget.rowIndex,
            weekProperty: widget.weekProperty,
            date: e.value,
            visiblePageDate: widget.visiblePageDate,
            dateTextStyle: widget.dateTextStyle,
            onCellTapped: widget.onCellTapped,
            todayMarkColor: widget.todayMarkColor,
            todayTextColor: widget.todayTextColor,
            events: widget.events,
          );
        }).toList(),
      ),
    );
  }
}

/// Cell of calendar.
///
/// Its height is circulated by [MeasureSize] and notified by [CellHeightController]
class DayCell extends HookConsumerWidget {
  const DayCell({
    super.key,
    required this.cellIndex,
    required this.rowIndex,
    required this.date,
    required this.visiblePageDate,
    required this.dateTextStyle,
    required this.onCellTapped,
    required this.todayMarkColor,
    required this.todayTextColor,
    required this.events,
    this.weekProperty,
  });
  final int cellIndex;
  final int rowIndex;
  final DateTime date;
  final DateTime visiblePageDate;
  final TextStyle? dateTextStyle;
  // final void Function(DateTime)? onCellTapped;
  final Future<bool?> Function(DateTime)? onCellTapped;
  final Color todayMarkColor;
  final Color todayTextColor;
  final List<CalendarEvent> events;
  final WeekProperty? weekProperty;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectIndex = ref.watch(selectIndexProvider);
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final notifier = ref.read(selectIndexProvider.notifier);
          notifier.state = "[$rowIndex][$cellIndex]";
          // selectIndex = "[$rowIndex][$cellIndex]";
          onCellTapped?.call(date).then((value) {
            notifier.state = "";
          });
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
              // right:
              //     BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
          ),
          child: MeasureSize(
            onChange: (size) {
              final sizeState = ref.read(cellHeightProvider);
              if (sizeState != null || size == null) {
                return;
              }
              final notifier = ref.read(cellHeightProvider.notifier);
              notifier.state = size.height;
            },
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                DayLabel(
                  isHightlight: selectIndex == "[$rowIndex][$cellIndex]",
                  weekProperty: weekProperty,
                  date: date,
                  visiblePageDate: visiblePageDate,
                  dateTextStyle: dateTextStyle,
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: EventLabels(
                    date: date,
                    events: events,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayLabel extends StatelessWidget {
  const _TodayLabel({
    Key? key,
    required this.date,
    required this.dateTextStyle,
    required this.todayMarkColor,
    required this.todayTextColor,
  }) : super(key: key);

  final DateTime date;
  final TextStyle? dateTextStyle;
  final Color todayMarkColor;
  final Color todayTextColor;

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context)
        .textTheme
        .bodySmall!
        .copyWith(fontWeight: FontWeight.w500);
    final textStyle = caption.merge(dateTextStyle);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: todayMarkColor,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: todayTextColor,
          ),
        ),
      ),
    );
  }
}

class DayLabel extends StatelessWidget {
  const DayLabel({
    super.key,
    required this.date,
    required this.visiblePageDate,
    required this.dateTextStyle,
    this.weekProperty,
    this.isHightlight = false,
  });

  final DateTime date;
  final DateTime visiblePageDate;
  final TextStyle? dateTextStyle;
  final WeekProperty? weekProperty;
  final bool isHightlight;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = visiblePageDate.month == date.month;
    final caption = Theme.of(context).textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface);
    final textStyle = caption.merge(dateTextStyle);
    return Container(
      height: 20,
      width: 20,
      margin: EdgeInsets.symmetric(vertical: dayLabelVerticalMargin.toDouble()),
      // height: dayLabelContentHeight.toDouble(),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHightlight
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent),
      child: Center(
        child: Text(
          date.day.toString(),
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
            color: isHightlight
                ? Colors.white
                : isCurrentMonth && date.weekday == 7
                    ? weekProperty!.sundayColor
                    : isCurrentMonth
                        ? textStyle.color
                        : date.weekday == 7
                            ? weekProperty!.sundayColor.withOpacity(0.4)
                            : textStyle.color!.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

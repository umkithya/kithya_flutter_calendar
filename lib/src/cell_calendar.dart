import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kithya_flutter_calendar/src/header_property.dart';

import 'calendar_event.dart';
import 'components/days_of_the_week.dart';
import 'components/days_row/days_row.dart';
import 'components/month_year_label.dart';
import 'controllers/cell_calendar_page_controller.dart';
import 'date_extension.dart';
import 'week_property.dart';

typedef DaysBuilder = Widget Function(int dayIndex);

typedef MonthYearBuilder = Widget Function(DateTime? visibleDateTime);

final currentDateProvider = StateProvider((ref) => DateTime.now());

// /// Calendar widget like a Google Calendar
// ///
// /// Expected to be used in full screen

class CellCalendar extends StatelessWidget {
  const CellCalendar(
      {super.key,
      this.cellCalendarPageController,
      this.daysOfTheWeekBuilder,
      this.monthYearLabelBuilder,
      this.dateTextStyle,
      this.weekProperty,
      required this.events,
      this.onPageChanged,
      this.onCellTapped,
      required this.todayMarkColor,
      required this.todayTextColor,
      this.headerProperty});
  final CellCalendarPageController? cellCalendarPageController;

  /// Builder to show days of the week labels
  ///
  /// 0 for Sunday, 6 for Saturday.
  /// By default, it returns English labels
  final DaysBuilder? daysOfTheWeekBuilder;

  final MonthYearBuilder? monthYearLabelBuilder;

  final TextStyle? dateTextStyle;
  final WeekProperty? weekProperty;
  final HeaderProperty? headerProperty;

  final List<CalendarEvent> events;
  final void Function(DateTime firstDate, DateTime lastDate)? onPageChanged;
  final Future<bool?> Function(DateTime)? onCellTapped;
  final Color todayMarkColor;
  final Color todayTextColor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: CalendarPageView(
        headerProperty: headerProperty ?? HeaderProperty(),
        weekProperty: weekProperty ?? WeekProperty(),
        cellCalendarPageController: cellCalendarPageController,
        daysOfTheWeekBuilder: daysOfTheWeekBuilder,
        monthYearLabelBuilder: monthYearLabelBuilder,
        dateTextStyle: dateTextStyle,
        events: events,
        onPageChanged: onPageChanged,
        onCellTapped: onCellTapped,
        todayMarkColor: todayMarkColor,
        todayTextColor: todayTextColor,
      ),
    );
  }
}

class CalendarPageView extends HookConsumerWidget {
  const CalendarPageView({
    super.key,
    this.weekProperty,
    this.headerProperty,
    required this.cellCalendarPageController,
    required this.daysOfTheWeekBuilder,
    required this.monthYearLabelBuilder,
    required this.dateTextStyle,
    required this.events,
    required this.onPageChanged,
    required this.onCellTapped,
    required this.todayMarkColor,
    required this.todayTextColor,
  });
  final CellCalendarPageController? cellCalendarPageController;
  final HeaderProperty? headerProperty;

  /// Builder to show days of the week labels
  ///
  /// 0 for Sunday, 6 for Saturday.
  /// By default, it returns English labels
  final DaysBuilder? daysOfTheWeekBuilder;

  final MonthYearBuilder? monthYearLabelBuilder;

  final TextStyle? dateTextStyle;

  final List<CalendarEvent> events;
  final WeekProperty? weekProperty;

  final void Function(DateTime firstDate, DateTime lastDate)? onPageChanged;
  final Future<bool?> Function(DateTime)? onCellTapped;
  final Color todayMarkColor;
  final Color todayTextColor;
  DateTime _getFirstDay(DateTime dateTime) {
    final firstDayOfTheMonth = DateTime(dateTime.year, dateTime.month, 1);
    return firstDayOfTheMonth.add(firstDayOfTheMonth.weekday.daysDuration);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //header
        MonthYearLabel(
          controller:
              cellCalendarPageController ?? CellCalendarPageController(),
          headerProperty: headerProperty,
          monthYearLabelBuilder: monthYearLabelBuilder,
        ),
        Expanded(
          child: PageView.builder(
            controller:
                cellCalendarPageController ?? CellCalendarPageController(),
            itemBuilder: (context, index) {
              return CalendarPage(
                weekProperty: weekProperty,
                visiblePageDate: index.visibleDateTime,
                daysOfTheWeekBuilder: daysOfTheWeekBuilder,
                dateTextStyle: dateTextStyle,
                onCellTapped: onCellTapped,
                todayMarkColor: todayMarkColor,
                todayTextColor: todayTextColor,
                events: events,
              );
            },
            onPageChanged: (index) {
              debugPrint("Index $index");
              ref.read(currentDateProvider.notifier).state =
                  index.visibleDateTime;
              final currentDateTime = ref.read(currentDateProvider);
              if (onPageChanged != null) {
                final currentFirstDate = _getFirstDay(currentDateTime);
                onPageChanged!(
                  currentFirstDate,
                  currentFirstDate.add(
                    const Duration(days: 41),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage(
      {super.key,
      required this.visiblePageDate,
      this.daysOfTheWeekBuilder,
      this.dateTextStyle,
      this.onCellTapped,
      required this.todayMarkColor,
      required this.todayTextColor,
      required this.events,
      this.weekProperty});
  final DateTime visiblePageDate;
  final DaysBuilder? daysOfTheWeekBuilder;
  final TextStyle? dateTextStyle;
  final Future<bool?> Function(DateTime)? onCellTapped;
  final Color todayMarkColor;
  final Color todayTextColor;
  final List<CalendarEvent> events;
  final WeekProperty? weekProperty;
  List<DateTime> _getCurrentDays(DateTime dateTime) {
    final List<DateTime> result = [];
    final firstDay = _getFirstDay(dateTime);
    result.add(firstDay);
    for (int i = 0; i + 1 < 42; i++) {
      result.add(firstDay.add(Duration(days: i + 1)));
    }
    return result;
  }

  DateTime _getFirstDay(DateTime dateTime) {
    final firstDayOfTheMonth = DateTime(dateTime.year, dateTime.month, 1);
    return firstDayOfTheMonth.add(firstDayOfTheMonth.weekday.daysDuration);
  }

  @override
  Widget build(BuildContext context) {
    final days = _getCurrentDays(visiblePageDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          DaysOfTheWeek(daysOfTheWeekBuilder, weekProperty),
          // const Text("H"),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) {
                  return DaysRow(
                    rowIndex: index,
                    weekProperty: weekProperty,
                    visiblePageDate: visiblePageDate,
                    dates: days.getRange(index * 7, (index + 1) * 7).toList(),
                    dateTextStyle: dateTextStyle,
                    onCellTapped: onCellTapped,
                    todayMarkColor: todayMarkColor,
                    todayTextColor: todayTextColor,
                    events: events,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

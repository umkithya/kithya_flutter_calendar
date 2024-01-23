import 'package:flutter/material.dart';

import '../cell_calendar.dart';
import '../week_property.dart';

/// Default days of the week
const List<String> _DaysOfTheWeek = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat'
];

/// Show the row of text from [_DaysOfTheWeek]
class DaysOfTheWeek extends StatelessWidget {
  const DaysOfTheWeek(this.daysOfTheWeekBuilder, this.weekProperty,
      {super.key});
  final WeekProperty? weekProperty;

  final DaysBuilder? daysOfTheWeekBuilder;

  Widget defaultLabels(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        _DaysOfTheWeek[index],
        textAlign: TextAlign.center,
        style:
            //  weekProperty?.textStyle?.copyWith(
            //         color: index == _DaysOfTheWeek.length - 1
            //             ? weekProperty?.saturdayColor
            //             : index == 0
            //                 ? weekProperty?.sundayColor
            //                 : null) ??
            weekProperty?.textStyle != null
                ? weekProperty?.textStyle?.copyWith(
                    color: index == 0 ? weekProperty!.sundayColor : null)
                : TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? weekProperty!.sundayColor : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        7,
        (index) {
          return Expanded(
            child: daysOfTheWeekBuilder?.call(index) ?? defaultLabels(index),
          );
        },
      ),
    );
  }
}

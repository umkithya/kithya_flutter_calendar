import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kithya_flutter_calendar/kithya_flutter_calendar.dart';

import 'sample_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final events = sampleEvents();
    final cellCalendarPageController = CellCalendarPageController();
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: CellCalendar(
          todayMarkColor: Colors.blue,
          todayTextColor: Colors.black,
          weekProperty: WeekProperty(
            sundayColor: Colors.red,
          ),
          cellCalendarPageController: cellCalendarPageController,
          events: events,
          // monthYearLabelBuilder: (datetime) {
          //   final year = datetime!.year.toString();
          //   final month = datetime.month.monthName;
          //   return Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 4),
          //     child: Row(
          //       children: [
          //         const SizedBox(width: 16),
          //         Text(
          //           "$month  $year",
          //           style: const TextStyle(
          //             fontSize: 24,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         const Spacer(),
          //         IconButton(
          //           padding: EdgeInsets.zero,
          //           icon: const Icon(Icons.calendar_today),
          //           onPressed: () {
          //             cellCalendarPageController.animateToDate(
          //               DateTime.now(),
          //               curve: Curves.linear,
          //               duration: const Duration(milliseconds: 300),
          //             );
          //           },
          //         )
          //       ],
          //     ),
          //   );
          // },
          onCellTapped: (date) async {
            final eventsOnTheDate = events.where((event) {
              final eventDate = event.eventDate;
              return eventDate.year == date.year &&
                  eventDate.month == date.month &&
                  eventDate.day == date.day;
            }).toList();

            await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text("${date.month.monthName} ${date.day}"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: eventsOnTheDate
                          .map(
                            (event) => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(bottom: 12),
                              color: event.eventBackgroundColor,
                              child: Text(
                                event.eventName,
                                style: event.eventTextStyle,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                });
            // debugPrint("rs:$rs");
            return true;
            // debugPrint("rs: $rs");
            // return rs;
          },
          onPageChanged: (firstDate, lastDate) {
            /// Called when the page was changed
            /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
          },
        ),
      ),
    );
  }
}

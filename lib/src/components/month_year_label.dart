import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../kithya_flutter_calendar.dart';

final indexProvider = StateProvider<int>((ref) => 0);

/// Label showing the date of current page
class MonthYearLabel extends HookConsumerWidget {
  const MonthYearLabel({
    this.monthYearLabelBuilder,
    this.controller,
    super.key,
    this.headerProperty,
  });

  final MonthYearBuilder? monthYearLabelBuilder;
  final HeaderProperty? headerProperty;
  final CellCalendarPageController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(indexProvider);
    final currentDateTime = ref.watch(currentDateProvider);
    final monthLabel = currentDateTime.month.monthName;
    final yearLabel = currentDateTime.year.toString();
    return monthYearLabelBuilder?.call(currentDateTime) ??
        Padding(
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 12,
            left: 18,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$monthLabel $yearLabel",
                style: headerProperty != null
                    ? headerProperty!.headerDateTextStyle ??
                        const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)
                    : const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (headerProperty!.showNavigation)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      splashRadius: 25,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (controller != null) {
                          ref.read(indexProvider.notifier).state = index - 1;
                          final updateIndex = ref.read(indexProvider);
                          // debugPrint("index-:$updateIndex");
                          controller!.animateToPage(updateIndex,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.linear);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      iconSize: 16,
                    ),
                    IconButton(
                        splashRadius: 25,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (controller != null) {
                            ref.read(indexProvider.notifier).state = index + 1;
                            final updateIndex = ref.read(indexProvider);
                            // debugPrint("index+:$updateIndex");
                            controller!.animateToPage(updateIndex,
                                duration: const Duration(
                                  milliseconds: 300,
                                ),
                                curve: Curves.linear);
                          }
                        },
                        iconSize: 16,
                        icon: const Icon(Icons.arrow_forward_ios))
                  ],
                )
            ],
          ),
        );
  }
}

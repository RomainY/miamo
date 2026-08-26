import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Vue calendrier (semaine/mois) du module Planification
/// (cahier-des-charges.md §3.2). Affiche un point par jour ayant au moins un
/// repas planifié.
class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, int> nombreRepasParJour;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.nombreRepasParJour,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<void>(
      locale: 'fr_FR',
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 730)),
      focusedDay: focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: (selected, focused) => onDaySelected(selected),
      onPageChanged: onPageChanged,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Mois'},
      eventLoader: (day) {
        final n =
            nombreRepasParJour[DateTime(day.year, day.month, day.day)] ?? 0;
        return List.filled(n, null);
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }
}

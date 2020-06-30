import 'package:calendaroo/widgets/calendar/calendar.widget.dart';
import 'package:calendaroo/widgets/upcoming-events/upcoming-events.widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
//    return CalendarWidget();
    return Column(children: [CalendarWidget(), UpcomingEventsWidget()]);
  }
}

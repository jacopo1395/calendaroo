import 'package:calendaroo/colors.dart';
import 'package:calendaroo/model/date.model.dart';
import 'package:calendaroo/redux/states/app.state.dart';
import 'package:calendaroo/services/shared-preferences.service.dart';
import 'package:calendaroo/utils/string.utils.dart';
import 'package:calendaroo/widgets/calendar/calendar.viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  CalendarController _calendarController;
  CalendarSize _calendarSize;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    _calendarSize = SharedPreferenceService().calendarSize;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void updateController(DateTime newSelectedDay) {
    if (_calendarController != null) {
      if (newSelectedDay != null
          // && CalendarUtils.removeTime(_calendarController.selectedDay) != CalendarUtils.removeTime(newSelectedDay)
          // workaround until restore of previous condition
          && (_calendarController.selectedDay.year != newSelectedDay.year || _calendarController.selectedDay.month != newSelectedDay.month || _calendarController.selectedDay.day != newSelectedDay.day)
          ) {
        setState(() {
          _calendarController.setSelectedDay(newSelectedDay);
        });
      }
    }
  }

  void _onDaySelected(CalendarViewModel store, DateTime day, List events) {
    store.selectDay(Date.convertToDate(day));
  }

  void _onVisibleDaysChanged(CalendarViewModel state, DateTime first,
      DateTime last, CalendarFormat format) {
    if (format == CalendarFormat.month) {
      SharedPreferenceService().setCalendarSize('month');
      _calendarSize = CalendarSize.MONTH;
    }
    if (format == CalendarFormat.twoWeeks) {
      SharedPreferenceService().setCalendarSize('twoWeeks');
      _calendarSize = CalendarSize.TWO_WEEKS;
    }
    if (format == CalendarFormat.week) {
      SharedPreferenceService().setCalendarSize('week');
      _calendarSize = CalendarSize.WEEK;
    }

    if (first.isBefore(calendarooState.state.calendarState.startRange)) {
      state.expandRange(
          Date.convertToDate(calendarooState.state.calendarState.startRange
              .subtract(Duration(days: 60))),
          calendarooState.state.calendarState.endRange);
    }
    if (last.isAfter(calendarooState.state.calendarState.endRange)) {
      state.expandRange(
          calendarooState.state.calendarState.startRange,
          Date.convertToDate(calendarooState.state.calendarState.endRange
              .add(Duration(days: 60))));
    }
  }

  void _onCalendarCreated(CalendarViewModel store, DateTime first,
      DateTime last, CalendarFormat format) {
    store.selectDay(Date.today());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CalendarViewModel>(
        converter: (store) => CalendarViewModel.fromStore(store),
        onWillChange: (oldViewModel, newViewModel) {
          updateController(newViewModel.selectedDay);
        },
        builder: (context, store) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: cyanGradient)),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  _buildHeaderTable(store),
                  _calendarSize != CalendarSize.HIDE
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildTableCalendarWithBuilders(store),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildHeaderTable(CalendarViewModel store) {
    var yearFormatter =
        DateFormat.yMMMM(Localizations.localeOf(context).toString());
    return Material(
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                _calendarSize != CalendarSize.HIDE
                    ? IconButton(
                        onPressed: () => _selectPrevious(),
                        icon: Icon(
                          Icons.chevron_left,
                          color: white,
                        ))
                    : SizedBox(
                        width: 48,
                      ),
                Text(
                  _calendarController == null ||
                          _calendarController.focusedDay == null
                      ? ''
                      : StringUtils.capitalize(
                          yearFormatter.format(_calendarController.focusedDay)),
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: white),
                ),
                _calendarSize != CalendarSize.HIDE
                    ? IconButton(
                        onPressed: () => _selectNext(),
                        icon: Icon(
                          Icons.chevron_right,
                          color: white,
                        ))
                    : SizedBox(),
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      setState(() {
                        switch (_calendarSize) {
                          case CalendarSize.HIDE:
                            _calendarSize = CalendarSize.MONTH;
                            _calendarController
                                .setCalendarFormat(CalendarFormat.month);
                            break;
                          case CalendarSize.WEEK:
                            _calendarSize = CalendarSize.HIDE;
                            break;
                          case CalendarSize.TWO_WEEKS:
                            _calendarSize = CalendarSize.WEEK;
                            _calendarController
                                .setCalendarFormat(CalendarFormat.week);
                            break;
                          case CalendarSize.MONTH:
                            _calendarSize = CalendarSize.TWO_WEEKS;
                            _calendarController
                                .setCalendarFormat(CalendarFormat.twoWeeks);
                            break;
                          default:
                            _calendarSize = CalendarSize.MONTH;
                            _calendarController
                                .setCalendarFormat(CalendarFormat.month);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.format_line_spacing,
                      color: white,
                    )),
                IconButton(
                    onPressed: () {
                      store.selectDay(Date.today());
                    },
                    icon: Icon(
                      Icons.today,
                      color: white,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders(CalendarViewModel store) {
    var locale = Localizations.localeOf(context);
    return TableCalendar(
      calendarController: _calendarController,
      events: store.eventMapped,
      headerVisible: false,
      initialCalendarFormat: _convertSizeToFormat(),
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: {
        CalendarFormat.month: 'month',
        CalendarFormat.twoWeeks: 'twoWeeks',
        CalendarFormat.week: 'week'
      },
      locale: locale.toString(),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        outsideHolidayStyle: TextStyle()
            .copyWith(fontWeight: FontWeight.w600, color: transparentWhite),
        outsideWeekendStyle: TextStyle()
            .copyWith(fontWeight: FontWeight.w600, color: transparentWhite),
        outsideStyle: TextStyle()
            .copyWith(fontWeight: FontWeight.w600, color: transparentWhite),
        weekendStyle:
            TextStyle().copyWith(fontWeight: FontWeight.w600, color: white),
        holidayStyle:
            TextStyle().copyWith(fontWeight: FontWeight.w600, color: white),
        weekdayStyle:
            TextStyle().copyWith(fontWeight: FontWeight.w600, color: white),
        eventDayStyle:
            TextStyle().copyWith(fontWeight: FontWeight.w600, color: white),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: white),
          weekdayStyle: TextStyle().copyWith(color: white)),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: white),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle().copyWith(fontSize: 16.0, color: blue),
                  ),
                ),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: transparentWhite),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0, color: darkBlue),
                ),
              ),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(_buildEventsMarker(date, events));
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(store, date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: (first, last, format) {
        // This setState updates the month label because this callback is called also when swiping the calendar
        setState(() {});
        _onVisibleDaysChanged(store, first, last, format);
      },
      onCalendarCreated:
          (DateTime first, DateTime last, CalendarFormat format) =>
              _onCalendarCreated(store, first, last, format),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    events = events.sublist(0, events.length > 3 ? 3 : events.length);
    return Positioned(
        bottom: 10,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events
                .map((e) => Padding(
                    padding: EdgeInsets.only(left: 1, right: 1),
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pink,
                      ),
                    )))
                .toList()));
  }

  void _selectPrevious() {
    var calendarFormat = _calendarController.calendarFormat;
    var focusesDay = _calendarController.focusedDay;
    var newFocus = focusesDay;
    if (_calendarController.calendarFormat == CalendarFormat.month) {
      if (focusesDay.month == 1) {
        newFocus = DateTime(focusesDay.year - 1, 12);
      } else {
        newFocus = DateTime(focusesDay.year, focusesDay.month - 1);
      }
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      if (_calendarController.visibleDays.take(7).contains(focusesDay)) {
        // in top row
        newFocus = focusesDay.subtract(const Duration(days: 7));
      } else {
        // in bottom row OR not visible
        newFocus = focusesDay.subtract(Duration(days: 14));
      }
    } else {
      newFocus = focusesDay.subtract(const Duration(days: 7));
    }
    setState(() {
      _calendarController.setFocusedDay(newFocus);
    });
  }

  void _selectNext() {
    var calendarFormat = _calendarController.calendarFormat;
    var focusesDay = _calendarController.focusedDay;
    var newFocus = focusesDay;
    if (_calendarController.calendarFormat == CalendarFormat.month) {
      if (focusesDay.month == 12) {
        newFocus = DateTime(focusesDay.year + 1, 12);
      } else {
        newFocus = DateTime(focusesDay.year, focusesDay.month + 1);
      }
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      if (!_calendarController.visibleDays.skip(7).contains(focusesDay)) {
        // in top row
        newFocus = focusesDay.add(const Duration(days: 7));
      } else {
        // in bottom row OR not visible
        newFocus = focusesDay.add(Duration(days: 14));
      }
    } else {
      newFocus = focusesDay.add(const Duration(days: 7));
    }
    setState(() {
      _calendarController.setFocusedDay(newFocus);
    });
  }

  CalendarFormat _convertSizeToFormat() {
    var calendarSize = SharedPreferenceService().calendarSize;
    switch (calendarSize) {
      case CalendarSize.HIDE:
        return CalendarFormat.month;
      case CalendarSize.WEEK:
        return CalendarFormat.week;
      case CalendarSize.TWO_WEEKS:
        return CalendarFormat.twoWeeks;
      case CalendarSize.MONTH:
        return CalendarFormat.month;
      default:
        return CalendarFormat.month;
    }
  }
}

enum CalendarSize { HIDE, WEEK, TWO_WEEKS, MONTH }

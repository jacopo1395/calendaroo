import 'package:calendaroo/colors.dart';
import 'package:calendaroo/model/event.model.dart';
import 'package:calendaroo/redux/actions/calendar.actions.dart';
import 'package:calendaroo/redux/states/app.state.dart';
import 'package:calendaroo/services/app-localizations.service.dart';
import 'package:calendaroo/services/calendar.service.dart';
import 'package:calendaroo/widgets/upcoming-events/upcoming-events.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../options.widget.dart';

class UpcomingEventsWidget extends StatefulWidget {
  @override
  _UpcomingEventsWidgetState createState() => _UpcomingEventsWidgetState();
}

class _UpcomingEventsWidgetState extends State<UpcomingEventsWidget>
    with TickerProviderStateMixin {
  AutoScrollController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      calendarooState.dispatch(SelectDay(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(32.0),
      topRight: Radius.circular(32.0),
    );
    return StoreConnector<AppState, UpcomingEventsViewModel>(
        converter: (store) => UpcomingEventsViewModel.fromStore(store),
        onDidChange: (viewModel) {
          try {
            _listController.scrollToIndex(
                CalendarService()
                    .getIndex(viewModel.eventMapped, viewModel.selectedDay),
                preferPosition: AutoScrollPosition.begin);

//            _animationController.forward(from: 0);
          } catch (e) {
            print('no events for selected day');
          }
        },
        builder: (context, store) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(color: white, borderRadius: radius),
              child: Stack(
                children: <Widget>[
                  ListView(
                      controller: _listController,
                      padding: EdgeInsets.all(16),
                      children: _buildAgenda(store)),
                ],
              ),
            ),
          );
        });
  }

  List<Widget> _buildAgenda(UpcomingEventsViewModel store) {
    var mapEvent = store.eventMapped;
    List<Widget> widgets = [];
    if (mapEvent == null || mapEvent.isEmpty) {
      return [_buildEmptyAgenda()];
    }

    var formatterTime =
        DateFormat.Hm(Localizations.localeOf(context).toString());
    var formatter =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString());
    for (var date in mapEvent.keys) {
      List<Widget> row = [];
      var list = mapEvent[date];
      row
        ..add(Container(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            formatter.format(date),
            style: Theme.of(context).textTheme.headline5,
          ),
        )))
        ..addAll(list
            .map((elem) => Container(
                  child: _buildCardEvent(store, elem, formatterTime),
                ))
            .toList())
        ..add(SizedBox(
          height: 16,
        ));
      AutoScrollTag dayGroup = AutoScrollTag(
        key: ValueKey(CalendarService().getIndex(mapEvent, date)),
        index: CalendarService().getIndex(mapEvent, date),
        controller: _listController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: row,
        ),
      );
      widgets.add(dayGroup);
    }
    return widgets;
  }

  GestureDetector _buildCardEvent(
      UpcomingEventsViewModel store, Event elem, DateFormat formatterTime) {
    return GestureDetector(
      onTap: () {
        store.openEvent(elem);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8,
        child: SizedBox(
          height: 68,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 45,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: blueGradient)),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      elem.title,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                        "${formatterTime.format(elem.start)} - ${formatterTime.format(elem.start)}",
                        style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              ),
              PopupMenuButton<Option>(
                onSelected: selectOption,
                color: white,
                icon: Icon(
                  Icons.more_vert,
                  color: grey,
                ),
                itemBuilder: (BuildContext context) {
                  return options.map((Option option) {
                    return PopupMenuItem<Option>(
                      value: option.setEvent(elem),
                      child: Theme(
                          data: Theme.of(context).copyWith(cardColor: white),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate(option.title),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: black),
                          )),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
//                    child: ListTile(
//                      leading: Container(
//                        decoration: BoxDecoration(
//                            gradient: LinearGradient(
//                                begin: Alignment.topRight,
//                                end: Alignment.bottomLeft,
//                                colors: [Colors.blue, Colors.red])),
//                      ),
//                      title: Column(
//                        children: <Widget>[
//                          Text(
//                            elem.title,
//                            style: Theme.of(context).textTheme.bodyText2,
//                          ),
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//                              Text(formatterTime.format(elem.start),
//                                  style: Theme.of(context)
//                                      .textTheme
//                                      .bodyText2),
//                              Text(formatterTime.format(elem.end),
//                                  style: Theme.of(context)
//                                      .textTheme
//                                      .bodyText2),
//                            ],
//                          ),
//                        ],
//                      ),
//                      trailing: PopupMenuButton<Option>(
//                        onSelected: selectOption,
//                        color: primaryWhite,
//                        icon: Icon(
//                          Icons.more_vert,
//                          color: primaryWhite,
//                        ),
//                        itemBuilder: (BuildContext context) {
//                          return options.map((Option option) {
//                            return PopupMenuItem<Option>(
//                              value: option.setEvent(elem),
//                              child: Theme(
//                                  data: Theme.of(context).copyWith(
//                                      cardColor: primaryWhite),
//                                  child: Text(
//                                    AppLocalizations.of(context).translate(option.title),
//                                    style: Theme.of(context)
//                                        .textTheme
//                                        .bodyText1
//                                        .copyWith(color: primaryBlack),
//                                  )),
//                            );
//                          }).toList();
//                        },
//                      ),
//                    ),
      ),
    );
  }

  Container _buildEmptyAgenda() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
          child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).noEvents,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          Container(
              margin: EdgeInsets.only(top: 32),
              child: Icon(
                Icons.event_available,
                size: 64,
                color: lightGrey,
              ))
        ],
      )),
    );
  }
}

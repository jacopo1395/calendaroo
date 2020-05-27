import 'package:calendaroo/pages/add-event/add-event.page.dart';
import 'package:calendaroo/pages/home.page.dart';
import 'package:calendaroo/pages/show-event/show-event.page.dart';
import 'package:flutter/material.dart';

const HOMEPAGE = '/home';
const ADD_EVENT = '/add_event';
const SHOW_EVENT = '/show_event';

MaterialPageRoute<dynamic> Function(RouteSettings) routes =
    (RouteSettings settings) {
  switch (settings.name) {
    case HOMEPAGE:
      return MaterialPageRoute(builder: (context) => HomePage(), settings: settings);
    case ADD_EVENT:
      return MaterialPageRoute(builder: (context) => AddEventPage(settings.arguments), settings: settings);
    case SHOW_EVENT:
      return MaterialPageRoute(builder: (context) => ShowEventPage(settings.arguments), settings: settings);
    default:
      return MaterialPageRoute(builder: (context) => HomePage(), settings: settings);
  }
};

import 'package:calendaroo/dao/database.service.dart';
import 'package:calendaroo/redux/actions/calendar.actions.dart';
import 'package:calendaroo/redux/states/app.state.dart';
import 'package:calendaroo/routes.dart';
import 'package:calendaroo/services/navigation.service.dart';
import 'package:calendaroo/services/notification.service.dart';
import 'package:calendaroo/services/shared-preferences.service.dart';
import 'package:redux/redux.dart';

class CalendarMiddleware extends MiddlewareClass<AppState> {
  @override
  void call(Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is AddEvent) {
      var id = await DatabaseService().saveEvent(action.event);
      action.event.setId(id);

      if (SharedPreferenceService().enableNotifications) {
        await NotificationService().scheduleForEvent(action.event);
      }
    }

    if (action is RemoveEvent) {
      await DatabaseService().deleteEvent(action.event.id);
      await NotificationService().cancelForEvent(action.event);
    }

    if (action is OpenEvent) {
        var event = await DatabaseService().findEventById(action.eventId);
        await NavigationService().navigateTo(DETAILS, arguments: event);
        next(FocusEvent(event));
    }


    next(action);
  }
}

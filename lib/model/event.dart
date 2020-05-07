import 'package:flutter/cupertino.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime start;
  DateTime end;
// TODO ...

  Event(
      {@required this.id,
      @required this.title,
      this.description,
      this.start,
      this.end});


  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['start'] = start.toIso8601String();
    map['end'] = end.toIso8601String();
    return map;
  }

}

import 'package:flutter/cupertino.dart';

class Event {
  int id;
  String uuid;
  String title;
  String description;
  DateTime start;
  DateTime end;

  Event(
      {@required this.id,
      @required this.uuid,
      this.title,
      this.description,
      this.start,
      this.end});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['uuid'] = uuid;
    map['title'] = title;
    map['description'] = description;
    map['start'] = start.toIso8601String();
    map['end'] = end.toIso8601String();
    return map;
  }

  Event setId(int id) {
    this.id = id;
    return this;
  }
}

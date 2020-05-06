import 'package:calendaroo/colors.dart';
import 'package:calendaroo/model/event.dart';
import 'package:calendaroo/redux/states/app.state.dart';
import 'package:calendaroo/widgets/new-event/new-event.viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';


class NewEventWidget extends StatefulWidget {
  @override
  _NewEventWidgetState createState() => _NewEventWidgetState();
}

class _NewEventWidgetState extends State<NewEventWidget> {
  final _formKey = GlobalKey<FormState>();

  String _title;
  String _description;
  DateTime _start;
  DateTime _finish;

//  var _formatter = new DateFormat.yMMMMd().add_Hm();

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _finish = DateTime.now().add(Duration(days: 1));
  }


  // TODO grafica e translate
  @override
  Widget build(BuildContext context) {
    var _formatter = new DateFormat.yMMMMd('it_IT'); // TODO locale
    return StoreConnector<AppState, NewEventViewModel>(
        converter: (store) => NewEventViewModel.fromStore(store),
        builder: (context, store) {
          return Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text('Crea Nuovo Evento', textAlign: TextAlign.left ,style: Theme.of(context).textTheme.title),
                ),
                Container(
                  decoration: BoxDecoration(color: backgroundForm),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                        child: TextFormField(
                          style: TextStyle(fontSize: 32),
                          decoration: new InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: 'Title'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                        child: TextFormField(
                          decoration: new InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: secondaryDarkBlue),
                              ),
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: 'Descrizione'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                  child: InkWell(
                      onTap: () => CupertinoRoundedDatePicker.show(
                            context,
                            minimumYear: 1700,
                            maximumYear: 3000,
                            textColor: primaryWhite,
                            background: secondaryBlue,
                            borderRadius: 16,
                            initialDatePickerMode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (newDate) {
                              setState(() {
                                _start = newDate;
                              });
                            },
                          ),
                      child: Text(_formatter.format(_start))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                  child: InkWell(
                      onTap: () => CupertinoRoundedDatePicker.show(
                            context,
                            minimumYear: 1700,
                            maximumYear: 3000,
                            textColor: primaryWhite,
                            background: secondaryBlue,
                            borderRadius: 16,
                            initialDatePickerMode: CupertinoDatePickerMode.time,
                            onDateTimeChanged: (newDate) {
                              setState(() {
                                _start = newDate;
                              });
                            },
                          ),
                      child: Text(_start.toString())),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
                  child: RaisedButton(
                    color: secondaryBlue,
                    onPressed: () {
                      store.createEvent(_buildEvent());
                    },
                    child: Text('crea', style: TextStyle(color: primaryWhite, fontSize: 32),),
                  ),
                )
              ],
            ),
          );
        });
  }

  Event _buildEvent() {
    var uuid = Uuid();
    return Event(
        id: null,
        title: _title,
        description: _description,
        start: _start,
        finish: _finish);
  }
}
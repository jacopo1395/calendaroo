import 'package:calendaroo/constants.dart';
import 'package:calendaroo/main.dart';
import 'package:calendaroo/services/initializer-app.service.dart';
import 'package:calendaroo/services/shared-preferences.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'environment.dart';

void main() async {
  await setUp();
  runApp(MyApp());
}

Future<void> setUp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceService().getSharedPreferencesInstance();
  Environment().environment = INTEGRATION;
  Environment().version = VERSION;
  InitializerAppService().preLoadingData();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
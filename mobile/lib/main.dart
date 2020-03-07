import 'dart:async';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:inkino/message_provider.dart';
import 'package:inkino/ui/main_page.dart';
import 'package:key_value_store_flutter/key_value_store_flutter.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // If you're running an application and need to access the binary messenger before
  // `runApp()` has been called (for example, during plugin initialization), then
  // you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final keyValueStore = FlutterKeyValueStore(prefs);
  final store = createStore(Client(), keyValueStore);

  // NoSuchMethodError: The getter 'languageCode' was called on null.
  while (ui.window.locale == null) {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  FinnkinoApi.useFinnish = ui.window.locale.languageCode == 'fi';
  runApp(InKinoApp(store));
}

final supportedLocales = const [
  const Locale('en', 'US'),
  const Locale('fi', 'FI'),
];

final localizationsDelegates = <LocalizationsDelegate>[
  const InKinoLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

class InKinoApp extends StatefulWidget {
  InKinoApp(this.store);
  final Store<AppState> store;

  @override
  _InKinoAppState createState() => _InKinoAppState();
}

class _InKinoAppState extends State<InKinoApp> {
  @override
  void initState() {
    super.initState();
    widget.store.dispatch(InitAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: 'inKino',
        theme: ThemeData(
          primaryColor: const Color(0xFF1C306D),
          accentColor: const Color(0xFFFFAD32),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const MainPage(),
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
      ),
    );
  }
}

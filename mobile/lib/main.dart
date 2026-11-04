import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_text.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: systemOverlayStyle,
    child: MaterialApp(
      title: 'PayDo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: Center(child: Text('hello', style: AppText.base)),
      ),
    ),
  );
}

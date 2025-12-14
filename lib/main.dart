import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/routes.dart';

import 'home_page.dart';
import 'report_status_page.dart';
import 'alerts_page.dart';
import 'resources_page.dart';
import 'contacts_page.dart';
import 'roads_page.dart';
import 'past_quakes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔴 ALT MENÜ TUŞLARINI GİZLE + EDGE TO EDGE
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  /// 🔴 STATUS BAR / APPBAR ARASI BOŞLUĞU KALDIR
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EchoApp());
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECHO',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          toolbarHeight: 48, // 🔴 compact appbar
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),

      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => const HomePage(),
        Routes.report: (_) => const ReportStatusPage(),
        Routes.alerts: (_) => const AlertsPage(),
        Routes.resources: (_) => const ResourcesPage(),
        Routes.contacts: (_) => const ContactsPage(),
        Routes.roads: (_) => const RoadsPage(),
        Routes.pastQuakes: (_) => const PastQuakesPage(),
      },
    );
  }
}

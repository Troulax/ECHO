import 'package:flutter/material.dart';

import 'home_page.dart';
import 'report_status_page.dart';
import 'alerts_page.dart';
import 'resources_page.dart';
import 'contacts_page.dart';
import 'roads_page.dart';


void main() => runApp(const EchoApp());

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECHO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/report': (_) => const ReportStatusPage(),
        '/alerts': (_) => const AlertsPage(),      
        '/resources': (_) => const ResourcesPage(), 
        '/contacts': (_) => const ContactsPage(),  
        '/roads': (_) => const RoadsPage(),       
      }
    );
  }
}

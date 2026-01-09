import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'screens/nearest_shelters_page.dart';

import 'services/routes.dart';
import 'data/app_container.dart';

import 'login_page.dart';
import 'signup_page.dart';

import 'home_page.dart';
import 'report_status_page.dart';
import 'alerts_page.dart';
import 'resources_page.dart';
import 'contacts_page.dart';
import 'roads_page.dart';
import 'past_quakes_page.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Google Maps - Android platform view stabilitesi (Hybrid Composition)
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  // ✅ İlk açılışta admin kullanıcısını DB'ye ekle (yoksa)
  await authRepo.seedAdminIfNeeded();

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
          toolbarHeight: 48,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),

      // ✅ Uygulama açılınca önce login
      initialRoute: Routes.login,

      routes: {
        // Auth
        Routes.login: (_) => const LoginPage(),
        Routes.signup: (_) => const SignUpPage(),

        // ✅ Taskbar'lı ana kabuk
        Routes.root: (_) => const RootShell(),

        // Diğer sayfalar (istersen yine push ile kullanılabilir)
        Routes.home: (_) => const HomePage(),
        Routes.report: (_) => const ReportStatusPage(),
        Routes.alerts: (_) => const AlertsPage(),
        Routes.resources: (_) => const ResourcesPage(),
        Routes.contacts: (_) => const ContactsPage(),
        Routes.roads: (_) => const RoadsPage(),
        Routes.pastQuakes: (_) => PastQuakesPage(),
        Routes.nearestShelters: (_) => const NearestSheltersPage(),
      },
    );
  }
}

/// ✅ Alt görev çubuğu (NavigationBar) burada
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    AlertsPage(),
    ResourcesPage(),
    ContactsPage(),
    RoadsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = _index.clamp(0, _pages.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Uyarılar',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Kaynaklar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Tanıdıklar',
          ),
          NavigationDestination(
            icon: Icon(Icons.traffic_outlined),
            selectedIcon: Icon(Icons.traffic),
            label: 'Yol',
          ),
        ],
      ),
    );
  }
}

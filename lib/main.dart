import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/pages/home/home_screen_pengepul.dart';
import 'package:namer_app/pages/splash.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home/home_screen_toko.dart';
import 'pages/profile/profile_screen.dart';
import 'pages/login/login.dart';
import 'pages/riwayat/riwayat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'LimbahPB',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.robotoTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 15, 1, 214)),
        ),
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatefulWidget {
  final String role; // Tambahkan role sebagai parameter
  final String name; // Tambahkan name sebagai parameter
  final String email; // Tambahkan email sebagai parameter
  final int id;

  MyHomePage({required this.role, required this.name, required this.email, required this.id});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    if (widget.role == 'pengepul') {
      return [
        PengepulDashboard(
          id: widget.id,
        ), // Halaman untuk pengepul
        ProfilScreen(
          name: widget.name,
          email: widget.email,
          onLogout: _handleLogout,
          onUpdatePassword: _handleUpdatePassword,
        ),
      ];
    } else {
      return [
        HomeScreenToko(
          id: widget.id,
        ),
        RiwayatScreen(
          id: widget.id
        ),
        ProfilScreen(
          name: widget.name,
          email: widget.email,
          onLogout: _handleLogout,
          onUpdatePassword: _handleUpdatePassword,
        ),
      ];
    }
  }

  List<BottomNavigationBarItem> get _bottomNavBarItems {
    if (widget.role == 'pengepul') {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    // Implement your logout logic here
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginPage(),
    ));
  }

  void _handleUpdatePassword() {
    // Implement your update password logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update Password clicked')),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set index pertama sesuai role
    if (widget.role == 'pengepul') {
      _selectedIndex = 0; // Mulai dengan dashboard pengepul
    } else {
      _selectedIndex = 0; // Mulai dengan dashboard toko
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 15, 1, 214),
        onTap: _onItemTapped,
      ),
    );
  }
}

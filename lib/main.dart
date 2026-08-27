import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Theme
import 'widgets/app_theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/conductor_provider.dart';
import 'providers/micro_provider.dart';
import 'providers/interno_provider.dart';
import 'providers/ruta_provider.dart';
import 'providers/parada_provider.dart';
import 'providers/turno_provider.dart';
import 'providers/propietario_provider.dart';
import 'providers/asignacion_turno_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/conductor/conductor_list_screen.dart';
import 'screens/micro/micro_list_screen.dart';
import 'screens/interno/interno_list_screen.dart';
import 'screens/ruta/ruta_list_screen.dart';
import 'screens/parada/parada_list_screen.dart';
import 'screens/turno/turno_list_screen.dart';
import 'screens/propietario/propietario_list_screen.dart';
import 'screens/asignacion_turno/asignacion_turno_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConductorProvider()),
        ChangeNotifierProvider(create: (_) => MicroProvider()),
        ChangeNotifierProvider(create: (_) => InternoProvider()),
        ChangeNotifierProvider(create: (_) => RutaProvider()),
        ChangeNotifierProvider(create: (_) => ParadaProvider()),
        ChangeNotifierProvider(create: (_) => TurnoProvider()),
        ChangeNotifierProvider(create: (_) => PropietarioProvider()),
        ChangeNotifierProvider(create: (_) => AsignacionTurnoProvider()),
      ],
      child: const Linea61App(),
    ),
  );
}

class Linea61App extends StatelessWidget {
  const Linea61App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Línea 61',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InitialScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/conductores': (context) => const ConductorListScreen(),
        '/micros': (context) => const MicroListScreen(),
        '/internos': (context) => const InternoListScreen(),
        '/rutas': (context) => const RutaListScreen(),
        '/paradas': (context) => const ParadaListScreen(),
        '/turnos': (context) => const TurnoListScreen(),
        '/propietarios': (context) => const PropietarioListScreen(),
        '/asignacion-turnos': (context) => const AsignacionTurnoListScreen(),
      },
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
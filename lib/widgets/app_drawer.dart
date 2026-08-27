import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, this.currentRoute = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.sidebarGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo / Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Línea 61',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Sections
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // GENERAL
                    _buildMenuTitle('GENERAL'),
                    _buildNavItem(
                      context,
                      icon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                      route: '/dashboard',
                    ),

                    // MÓDULOS
                    _buildMenuTitle('MÓDULOS'),

                    // Parametrización
                    _buildExpansionSection(
                      context,
                      icon: Icons.tune,
                      label: 'Parametrización',
                      isActive: [
                        '/conductores', '/propietarios', '/micros',
                        '/internos', '/rutas', '/paradas',
                      ].any((r) => currentRoute.startsWith(r)),
                      children: [
                        _buildSubNavItem(context, icon: Icons.badge_outlined, label: 'Conductores', route: '/conductores'),
                        _buildSubNavItem(context, icon: Icons.contact_mail_outlined, label: 'Propietarios', route: '/propietarios'),
                        _buildSubNavItem(context, icon: Icons.directions_bus_outlined, label: 'Micros', route: '/micros'),
                        _buildSubNavItem(context, icon: Icons.dns_outlined, label: 'Internos', route: '/internos'),
                        _buildSubNavItem(context, icon: Icons.signpost_outlined, label: 'Rutas', route: '/rutas'),
                        _buildSubNavItem(context, icon: Icons.location_on_outlined, label: 'Paradas', route: '/paradas'),
                      ],
                    ),

                    // Transacciones
                    _buildExpansionSection(
                      context,
                      icon: Icons.swap_horiz,
                      label: 'Transacciones',
                      isActive: currentRoute.startsWith('/turnos'),
                      children: [
                        _buildSubNavItem(context, icon: Icons.assignment_outlined, label: 'Asignación de Turnos', route: '/asignacion-turnos'),
                        _buildSubNavItem(context, icon: Icons.access_time_outlined, label: 'Horarios de Turno', route: '/turnos'),
                      ],
                    ),

                    // CONFIGURACIÓN
                    _buildMenuTitle('CONFIGURACIÓN'),
                    _buildNavItem(
                      context,
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      route: '/logout',
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    VoidCallback? onTap,
  }) {
    final isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? AppTheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {
            Navigator.of(context).pop();
            if (currentRoute != route) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isActive,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(left: 8),
        leading: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        iconColor: Colors.white.withValues(alpha: 0.6),
        collapsedIconColor: Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isActive ? AppTheme.accent.withValues(alpha: 0.3) : Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        children: children,
      ),
    );
  }

  Widget _buildSubNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute.startsWith(route);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isActive ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop();
            if (currentRoute != route) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.86), size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    Navigator.of(context).pop();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

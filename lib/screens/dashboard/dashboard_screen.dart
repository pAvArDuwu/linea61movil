import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de Control y Seguimiento de Micros',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
            Text(
              'Línea 61 · Santa Cruz - Bolivia',
              style: TextStyle(fontSize: 12, color: AppTheme.muted.withValues(alpha: 0.8)),
            ),
          ],
        ),
        actions: [
          // Notificaciones
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.muted),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          // Avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppTheme.avatarGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel general',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'Monitoreo operativo de la línea 61 · Santa Cruz',
                      style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stat Cards (2x2 grid)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                StatCard(
                  title: 'Micros activos',
                  value: '24',
                  icon: Icons.directions_bus,
                ),
                StatCard(
                  title: 'Conductores disponibles',
                  value: '18',
                  icon: Icons.badge,
                  isAccent: true,
                ),
                StatCard(
                  title: 'Recorridos activos',
                  value: '11',
                  icon: Icons.map,
                ),
                StatCard(
                  title: 'Fuera de servicio',
                  value: '3',
                  icon: Icons.build,
                  isAccent: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Monitoreo en tiempo real (mapa placeholder)
            Container(
              decoration: AppTheme.cardSoftDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monitoreo en tiempo real',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Seguimiento de la flota',
                              style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'En vivo',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Map placeholder
                  Container(
                    height: 200,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF8FBFF), Color(0xFFEEF4FB)],
                      ),
                      border: Border.all(color: const Color(0xFFE5EBF2)),
                    ),
                    child: Stack(
                      children: [
                        // Grid pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),
                        // Pulse dots
                        _buildPulseDot(top: 40, left: 50),
                        _buildPulseDot(top: 80, left: 180),
                        _buildPulseDot(top: 130, left: 100),
                        // Info card
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: AppTheme.cardSoftDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ruta 61 · Centro - Terminal',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                                Text(
                                  'Última actualización hace 2 min',
                                  style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actividad reciente
            Container(
              decoration: AppTheme.cardSoftDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actividad reciente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem('Inicio de recorrido', 'Micro 201 · Línea 61 · 07:20'),
                  const SizedBox(height: 8),
                  _buildActivityItem('Fin de recorrido', 'Micro 145 · Terminal · 06:55'),
                  const SizedBox(height: 8),
                  _buildActivityItem('Última ubicación recibida', 'Av. Ballivián · Lat -17.78 / Lon -63.18'),
                  const SizedBox(height: 8),
                  _buildActivityItem('Alerta', 'Micro 308 con retraso de 12 min', isAlert: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estado de la flota
            Container(
              decoration: AppTheme.cardSoftDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado de la flota',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Última actualización del sistema',
                              style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 13),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/micros'),
                          child: const Text('Ver micros'),
                        ),
                      ],
                    ),
                  ),
                  // Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.tableBg),
                      headingTextStyle: const TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                      dataTextStyle: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                      columns: const [
                        DataColumn(label: Text('UNIDAD')),
                        DataColumn(label: Text('CONDUCTOR')),
                        DataColumn(label: Text('RUTA')),
                        DataColumn(label: Text('ESTADO')),
                        DataColumn(label: Text('VELOCIDAD')),
                      ],
                      rows: [
                        _buildFleetRow('Micro 201', 'René Morales', 'Ruta 61', 'En recorrido', '38 km/h'),
                        _buildFleetRow('Micro 145', 'María Paredes', 'Ruta 61', 'En terminal', '0 km/h'),
                        _buildFleetRow('Micro 308', 'Jorge Lanza', 'Ruta 61', 'Retrasado', '24 km/h'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlert ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isAlert ? AppTheme.accent : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseDot({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.16),
              blurRadius: 0,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildFleetRow(String unit, String driver, String route, String status, String speed) {
    Color statusColor;
    Color statusBg;
    if (status == 'Retrasado') {
      statusColor = AppTheme.accent;
      statusBg = AppTheme.accent.withValues(alpha: 0.12);
    } else if (status == 'En terminal') {
      statusColor = AppTheme.accent;
      statusBg = AppTheme.accent.withValues(alpha: 0.1);
    } else {
      statusColor = AppTheme.primary;
      statusBg = AppTheme.primary.withValues(alpha: 0.08);
    }

    return DataRow(cells: [
      DataCell(Text(unit, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(driver)),
      DataCell(Text(route)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
      )),
      DataCell(Text(speed)),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0B3C78).withValues(alpha: 0.07)
      ..strokeWidth = 1;
    const spacing = 38.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

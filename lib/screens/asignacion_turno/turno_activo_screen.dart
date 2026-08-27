import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/asignacion_turno.dart';
import '../../providers/asignacion_turno_provider.dart';
import '../../widgets/app_theme.dart';

class TurnoActivoScreen extends StatefulWidget {
  final AsignacionTurno asignacion;

  const TurnoActivoScreen({super.key, required this.asignacion});

  @override
  State<TurnoActivoScreen> createState() => _TurnoActivoScreenState();
}

class _TurnoActivoScreenState extends State<TurnoActivoScreen> {
  Timer? _gpsTimer;
  bool _enviandoGps = false;
  int _puntosEnviados = 0;
  String? _ultimoReporte;

  @override
  void initState() {
    super.initState();
    // Si el turno ya está en curso, simular o iniciar envío de GPS periódico
    if (widget.asignacion.estado == 'en_curso') {
      _iniciarEnvioGps();
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  void _iniciarEnvioGps() {
    setState(() => _enviandoGps = true);
    // Envío periódico de GPS cada 10 segundos
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _reportarUbicacion();
    });
  }

  void _detenerEnvioGps() {
    _gpsTimer?.cancel();
    setState(() => _enviandoGps = false);
  }

  Future<void> _reportarUbicacion() async {
    final prov = Provider.of<AsignacionTurnoProvider>(context, listen: false);
    
    // Coordenadas de prueba basadas en la parada de la ruta
    double lat = -17.7830;
    double lng = -63.1820;
    
    final res = await prov.enviarUbicacionGps(
      asignacionId: widget.asignacion.id!,
      latitud: lat,
      longitud: lng,
      velocidad: 35.0,
    );

    if (res != null && mounted) {
      setState(() {
        _puntosEnviados++;
        _ultimoReporte = DateTime.now().toLocal().toString().substring(11, 19);
      });

      // Si el backend completó automáticamente el turno
      if (res['data'] != null && res['data']['asignacion_estado'] == 'completado') {
        _detenerEnvioGps();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('¡Recorrido completado! El turno se cerró automáticamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.asignacion;
    final ruta = a.ruta;
    final paradas = ruta?.nombre != null ? [
      'Parada 1: Inicio de Ruta',
      'Parada 2: Estación Central',
      'Parada 3: Plaza Principal',
      'Parada 4: Final de Recorrido',
    ] : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento en Vivo de Turno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Unidad y Turno
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.directions_bus, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.micro?.placa ?? 'Micro', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Interno: ${a.micro?.internoId ?? "A-01"}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          (a.estado ?? 'EN CURSO').toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ruta', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                          Text(ruta?.nombre ?? 'Línea 61', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Turno', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                          Text(a.turno?.displayNombre ?? 'Mañana', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estado del GPS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _enviandoGps ? Icons.gps_fixed : Icons.gps_not_fixed,
                            color: _enviandoGps ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _enviandoGps ? 'Transmisión GPS Activa' : 'GPS en Pausa',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _enviandoGps ? Colors.green.shade700 : Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text('Puntos: $_puntosEnviados', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (_ultimoReporte != null) ...[
                    const SizedBox(height: 6),
                    Text('Última transmisión: $_ultimoReporte', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _reportarUbicacion(),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Enviar Posición GPS Ahora'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Secuencia de Paradas del Recorrido
            const Text('Recorrido y Paradas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const SizedBox(height: 8),
            Text('El sistema detectará automáticamente cada parada cumplida por GPS.', style: TextStyle(color: AppTheme.muted.withValues(alpha: 0.8), fontSize: 13)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paradas.length,
              itemBuilder: (ctx, i) {
                final isLast = i == paradas.length - 1;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isLast ? Colors.red.shade100 : AppTheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isLast ? Colors.red.shade800 : AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          paradas[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isLast)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
                          child: const Text('Cierre Automático', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
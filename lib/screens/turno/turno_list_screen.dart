import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/turno_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import 'turno_detail_screen.dart';
import 'turno_form_screen.dart';

class TurnoListScreen extends StatefulWidget {
  const TurnoListScreen({super.key});
  @override
  State<TurnoListScreen> createState() => _TurnoListScreenState();
}

class _TurnoListScreenState extends State<TurnoListScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { Provider.of<TurnoProvider>(context, listen: false).fetchAll(); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sistema de Control y Seguimiento de Micros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)), Text('Línea 61 · Santa Cruz - Bolivia', style: TextStyle(fontSize: 12, color: AppTheme.muted))])),
      drawer: const AppDrawer(currentRoute: '/turnos'),
      body: Consumer<TurnoProvider>(builder: (context, prov, _) {
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.calendar_today, color: AppTheme.primary, size: 22), SizedBox(width: 8), Text('Asignación de Turnos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary))]), SizedBox(height: 2), Text('Administra los turnos del sistema', style: TextStyle(color: AppTheme.muted, fontSize: 13))]),
            Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
              child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurnoFormScreen())), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 6), Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))]))))),
          ])),
          const SizedBox(height: 16),
          Expanded(child: prov.isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary)) : prov.turnos.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, size: 48, color: AppTheme.muted.withValues(alpha: 0.3)), const SizedBox(height: 8), const Text('No se encontraron turnos.', style: TextStyle(color: AppTheme.muted))])) :
            RefreshIndicator(onRefresh: () => prov.fetchAll(), color: AppTheme.primary, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: prov.turnos.length, itemBuilder: (ctx, i) {
              final t = prov.turnos[i];
              return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cardBorder)),
                child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.access_time, color: AppTheme.primary, size: 20)),
                  title: Text('Turno ${t.tipo ?? "—"}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${t.horaInicio ?? "—"} - ${t.horaFin ?? "—"}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => TurnoDetailScreen(turnoId: t.id!))),
                ));
            }))),
        ]);
      }),
    );
  }
}

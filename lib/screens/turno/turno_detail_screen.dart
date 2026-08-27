import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/turno_provider.dart';
import '../../widgets/app_theme.dart';
import 'turno_form_screen.dart';

class TurnoDetailScreen extends StatefulWidget {
  final int turnoId;
  const TurnoDetailScreen({super.key, required this.turnoId});
  @override
  State<TurnoDetailScreen> createState() => _TurnoDetailScreenState();
}

class _TurnoDetailScreenState extends State<TurnoDetailScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { Provider.of<TurnoProvider>(context, listen: false).fetchById(widget.turnoId); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Detalle del Turno')),
      body: Consumer<TurnoProvider>(builder: (context, prov, _) {
        final t = prov.selected;
        if (t == null) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Detalle del Turno', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
                Row(children: [OutlinedButton(onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => TurnoFormScreen(turno: t))); if (r == true) prov.fetchById(widget.turnoId); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)), child: const Text('Editar', style: TextStyle(fontSize: 13))),
                  const SizedBox(width: 8), OutlinedButton(onPressed: () async { final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('¿Eliminar turno?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí'))])); if (c == true && mounted) { await prov.delete(t.id!); if (mounted) Navigator.pop(context, true); } }, child: const Text('Eliminar', style: TextStyle(fontSize: 13)))])])),
            Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              _d('Tipo', t.tipo ?? '—'), const SizedBox(height: 12),
              Row(children: [Expanded(child: _d('Hora Inicio', t.horaInicio ?? '—')), const SizedBox(width: 12), Expanded(child: _d('Hora Fin', t.horaFin ?? '—'))]),
            ])),
            Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))), child: Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Volver')))),
          ])));
      }));
  }

  Widget _d(String l, String v) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.tableBg, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const SizedBox(height: 4), Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]));
}

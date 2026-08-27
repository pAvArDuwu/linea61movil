import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/interno_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'interno_form_screen.dart';

class InternoDetailScreen extends StatefulWidget {
  final int internoId;
  const InternoDetailScreen({super.key, required this.internoId});
  @override
  State<InternoDetailScreen> createState() => _InternoDetailScreenState();
}

class _InternoDetailScreenState extends State<InternoDetailScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { Provider.of<InternoProvider>(context, listen: false).fetchById(widget.internoId); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Detalle del Interno')),
      body: Consumer<InternoProvider>(builder: (context, prov, _) {
        final i = prov.selected;
        if (i == null) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Detalle del Interno', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
                Row(children: [OutlinedButton(onPressed: () async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => InternoFormScreen(interno: i))); if (r == true) prov.fetchById(widget.internoId); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)), child: const Text('Editar', style: TextStyle(fontSize: 13))),
                  if (i.estado == 'activo') ...[const SizedBox(width: 8), OutlinedButton(onPressed: () async { final c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('¿Desactivar?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí'))])); if (c == true && mounted) { await prov.delete(i.id!); if (mounted) Navigator.pop(context, true); } }, child: const Text('Desactivar', style: TextStyle(fontSize: 13)))]])])),
            Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(children: [Expanded(child: _d('Número Interno', i.numeroInterno)), const SizedBox(width: 12), Expanded(child: _d('Fecha Ingreso', i.fechaIngreso ?? '—'))]),
              const SizedBox(height: 12),
              _d('Observaciones', i.observaciones ?? '—'),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.tableBg, borderRadius: BorderRadius.circular(10)), child: Row(children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estado', style: TextStyle(color: AppTheme.muted, fontSize: 12)), const SizedBox(height: 4), StatusBadge(estado: i.estado)])])),
            ])),
            Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))), child: Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Volver')))),
          ])));
      }));
  }

  Widget _d(String l, String v) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.tableBg, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const SizedBox(height: 4), Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))]));
}

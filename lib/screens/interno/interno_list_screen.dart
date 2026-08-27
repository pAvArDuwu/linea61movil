import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/interno_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/status_badge.dart';
import 'interno_detail_screen.dart';
import 'interno_form_screen.dart';

class InternoListScreen extends StatefulWidget {
  const InternoListScreen({super.key});
  @override
  State<InternoListScreen> createState() => _InternoListScreenState();
}

class _InternoListScreenState extends State<InternoListScreen> {
  final _sc = TextEditingController();
  String _q = '';
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { Provider.of<InternoProvider>(context, listen: false).fetchAll(); }); }
  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sistema de Control y Seguimiento de Micros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)), Text('Línea 61 · Santa Cruz - Bolivia', style: TextStyle(fontSize: 12, color: AppTheme.muted))])),
      drawer: const AppDrawer(currentRoute: '/internos'),
      body: Consumer<InternoProvider>(builder: (context, prov, _) {
        final list = prov.internos.where((i) { if (_q.isEmpty) return true; return i.numeroInterno.toLowerCase().contains(_q.toLowerCase()); }).toList();
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.dns, color: AppTheme.primary, size: 22), SizedBox(width: 8), Text('Gestión de Internos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary))]), SizedBox(height: 2), Text('Administra los números de interno', style: TextStyle(color: AppTheme.muted, fontSize: 13))]),
            Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
              child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternoFormScreen())), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 6), Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))]))))),
          ])),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(controller: _sc, decoration: InputDecoration(hintText: 'Buscar por número de interno...', prefixIcon: const Icon(Icons.search, color: AppTheme.muted), suffixIcon: _q.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _sc.clear(); setState(() => _q = ''); }) : null), onChanged: (v) => setState(() => _q = v))),
          const SizedBox(height: 12),
          Expanded(child: prov.isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary)) : list.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.dns, size: 48, color: AppTheme.muted.withValues(alpha: 0.3)), const SizedBox(height: 8), const Text('No se encontraron internos.', style: TextStyle(color: AppTheme.muted))])) :
            RefreshIndicator(onRefresh: () => prov.fetchAll(), color: AppTheme.primary, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (ctx, i) {
              final item = list[i];
              return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cardBorder)),
                child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(item.numeroInterno, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)))),
                  title: Text('Interno N° ${item.numeroInterno}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(item.observaciones ?? 'Sin observaciones', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusBadge(estado: item.estado), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: AppTheme.muted)]),
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => InternoDetailScreen(internoId: item.id!))),
                ));
            }))),
        ]);
      }),
    );
  }
}

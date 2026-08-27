import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/propietario_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/status_badge.dart';
import 'propietario_detail_screen.dart';
import 'propietario_form_screen.dart';

class PropietarioListScreen extends StatefulWidget {
  const PropietarioListScreen({super.key});
  @override
  State<PropietarioListScreen> createState() => _PropietarioListScreenState();
}

class _PropietarioListScreenState extends State<PropietarioListScreen> {
  final _sc = TextEditingController();
  String _q = '';

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { Provider.of<PropietarioProvider>(context, listen: false).fetchAll(); }); }
  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sistema de Control y Seguimiento de Micros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)), Text('Línea 61 · Santa Cruz - Bolivia', style: TextStyle(fontSize: 12, color: AppTheme.muted))])),
      drawer: const AppDrawer(currentRoute: '/propietarios'),
      body: Consumer<PropietarioProvider>(builder: (context, prov, _) {
        final list = prov.propietarios.where((p) { if (_q.isEmpty) return true; final q = _q.toLowerCase(); return p.nombre.toLowerCase().contains(q) || p.apellido.toLowerCase().contains(q) || (p.ci ?? '').toLowerCase().contains(q); }).toList();
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.contact_mail, color: AppTheme.primary, size: 22), SizedBox(width: 8), Text('Gestión de Propietarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary))]), SizedBox(height: 2), Text('Administra los propietarios del sistema', style: TextStyle(color: AppTheme.muted, fontSize: 13))]),
            Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
              child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropietarioFormScreen())), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 6), Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))]))))),
          ])),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(controller: _sc, decoration: InputDecoration(hintText: 'Buscar por nombre, CI...', prefixIcon: const Icon(Icons.search, color: AppTheme.muted), suffixIcon: _q.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _sc.clear(); setState(() => _q = ''); }) : null), onChanged: (v) => setState(() => _q = v))),
          const SizedBox(height: 12),
          Expanded(child: prov.isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary)) : list.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.contact_mail, size: 48, color: AppTheme.muted.withValues(alpha: 0.3)), const SizedBox(height: 8), const Text('No se encontraron propietarios.', style: TextStyle(color: AppTheme.muted))])) :
            RefreshIndicator(onRefresh: () => prov.fetchAll(), color: AppTheme.primary, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: list.length, itemBuilder: (ctx, i) {
              final p = list[i];
              return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cardBorder)),
                child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFDE8EC), Color(0xFFF8C4CE)]), borderRadius: BorderRadius.circular(21)), child: Center(child: Text(p.iniciales, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 14)))),
                  title: Text(p.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CI: ${p.ci ?? "—"}', style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontFamily: 'monospace')), Text(p.telefono ?? '—', style: const TextStyle(fontSize: 12, color: AppTheme.muted))]),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusBadge(estado: p.estado), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: AppTheme.muted)]),
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PropietarioDetailScreen(propietarioId: p.id!))),
                ));
            }))),
        ]);
      }),
    );
  }
}

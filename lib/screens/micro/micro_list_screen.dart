import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/micro_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/status_badge.dart';
import 'micro_detail_screen.dart';
import 'micro_form_screen.dart';

class MicroListScreen extends StatefulWidget {
  const MicroListScreen({super.key});
  @override
  State<MicroListScreen> createState() => _MicroListScreenState();
}

class _MicroListScreenState extends State<MicroListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MicroProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sistema de Control y Seguimiento de Micros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          Text('Línea 61 · Santa Cruz - Bolivia', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
        ]),
      ),
      drawer: const AppDrawer(currentRoute: '/micros'),
      body: Consumer<MicroProvider>(
        builder: (context, provider, _) {
          final filtered = provider.micros.where((m) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return m.placa.toLowerCase().contains(q) || m.marca.toLowerCase().contains(q) || m.modelo.toLowerCase().contains(q);
          }).toList();

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.directions_bus, color: AppTheme.primary, size: 22),
                    SizedBox(width: 8),
                    Text('Gestión de Micros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ]),
                  SizedBox(height: 2),
                  Text('Administra los vehículos del sistema', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ]),
                Container(
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
                  child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MicroFormScreen())),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 6), Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))])),
                  )),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(controller: _searchController, decoration: InputDecoration(hintText: 'Buscar por placa, modelo, marca...', prefixIcon: const Icon(Icons.search, color: AppTheme.muted), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null), onChanged: (v) => setState(() => _searchQuery = v))),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : filtered.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.directions_bus, size: 48, color: AppTheme.muted.withValues(alpha: 0.3)), const SizedBox(height: 8), const Text('No se encontraron micros.', style: TextStyle(color: AppTheme.muted))]))
                  : RefreshIndicator(onRefresh: () => provider.fetchAll(), color: AppTheme.primary, child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filtered.length, itemBuilder: (context, index) {
                      final m = filtered[index];
                      return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cardBorder)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                            child: Text(m.placa, style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700, fontSize: 12))),
                          title: Text(m.vehiculoCompleto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${m.anioFabricacion ?? 'Sin año'} · ${m.capacidadPasajeros} pax', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [StatusBadge(estado: m.estado), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: AppTheme.muted)]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MicroDetailScreen(microId: m.id!))),
                        ));
                    })),
            ),
          ]);
        },
      ),
    );
  }
}

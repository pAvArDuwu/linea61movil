import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conductor_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/status_badge.dart';
import 'conductor_detail_screen.dart';
import 'conductor_form_screen.dart';

class ConductorListScreen extends StatefulWidget {
  const ConductorListScreen({super.key});

  @override
  State<ConductorListScreen> createState() => _ConductorListScreenState();
}

class _ConductorListScreenState extends State<ConductorListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConductorProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sistema de Control y Seguimiento de Micros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            Text('Línea 61 · Santa Cruz - Bolivia', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/conductores'),
      body: Consumer<ConductorProvider>(
        builder: (context, provider, _) {
          final filtered = provider.conductores.where((c) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return c.nombre.toLowerCase().contains(q) ||
                c.apellido.toLowerCase().contains(q) ||
                c.ci.toLowerCase().contains(q) ||
                c.correo.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.badge, color: AppTheme.primary, size: 22),
                            SizedBox(width: 8),
                            Text('Gestión de Conductores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('Administra los conductores del sistema', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConductorFormScreen())),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, CI, correo...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 12),

              // List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : provider.error != null
                        ? Center(child: Text(provider.error!, style: const TextStyle(color: AppTheme.accent)))
                        : filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.badge, size: 48, color: AppTheme.muted.withValues(alpha: 0.3)),
                                    const SizedBox(height: 8),
                                    const Text('No se encontraron conductores.', style: TextStyle(color: AppTheme.muted)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchAll(),
                                color: AppTheme.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final c = filtered[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.cardBorder),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFDE8EC), Color(0xFFF8C4CE)],
                                            ),
                                            borderRadius: BorderRadius.circular(21),
                                          ),
                                          child: Center(
                                            child: Text(
                                              c.iniciales,
                                              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        title: Text(c.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('CI: ${c.ci}', style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontFamily: 'monospace')),
                                            Text(c.telefono, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            StatusBadge(estado: c.estado),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.chevron_right, color: AppTheme.muted),
                                          ],
                                        ),
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConductorDetailScreen(conductorId: c.id!))),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}

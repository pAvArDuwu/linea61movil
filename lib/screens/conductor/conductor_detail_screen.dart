import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conductor_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/status_badge.dart';
import 'conductor_form_screen.dart';

class ConductorDetailScreen extends StatefulWidget {
  final int conductorId;
  const ConductorDetailScreen({super.key, required this.conductorId});

  @override
  State<ConductorDetailScreen> createState() => _ConductorDetailScreenState();
}

class _ConductorDetailScreenState extends State<ConductorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConductorProvider>(context, listen: false).fetchById(widget.conductorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Detalle del Conductor'),
      ),
      body: Consumer<ConductorProvider>(
        builder: (context, provider, _) {
          final c = provider.selected;
          if (c == null) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Detalle del Conductor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ConductorFormScreen(conductor: c)));
                                if (result == true) provider.fetchById(widget.conductorId);
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                              child: const Text('Editar', style: TextStyle(fontSize: 13)),
                            ),
                            if (c.estado == 'activo') ...[
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('¿Desactivar?'),
                                      content: const Text('¿Desactivar este conductor?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && mounted) {
                                    await provider.delete(c.id!);
                                    if (mounted) Navigator.pop(context, true);
                                  }
                                },
                                child: const Text('Desactivar', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Detail fields
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _detailField('Nombre Completo', c.nombreCompleto)),
                            const SizedBox(width: 12),
                            Expanded(child: _detailField('CI', c.ci)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppTheme.tableBg, borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Estado', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    StatusBadge(estado: c.estado),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _detailField('Correo Electrónico', c.correo)),
                            const SizedBox(width: 12),
                            Expanded(child: _detailField('Teléfono', c.telefono)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Volver'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.tableBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

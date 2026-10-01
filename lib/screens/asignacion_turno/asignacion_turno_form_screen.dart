import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/asignacion_turno_provider.dart';
import '../../providers/conductor_provider.dart';
import '../../providers/micro_provider.dart';
import '../../providers/ruta_provider.dart';
import '../../providers/turno_provider.dart';
import '../../widgets/app_theme.dart';

class AsignacionTurnoFormScreen extends StatefulWidget {
  const AsignacionTurnoFormScreen({super.key});

  @override
  State<AsignacionTurnoFormScreen> createState() => _AsignacionTurnoFormScreenState();
}

class _AsignacionTurnoFormScreenState extends State<AsignacionTurnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();
  int? _turnoId;
  int? _rutaId;
  int? _microId;
  int? _conductorId;
  DateTime _fecha = DateTime.now();
  bool _loading = false;
  bool _loadingOptions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    await Future.wait([
      context.read<ConductorProvider>().fetchAll(),
      context.read<MicroProvider>().fetchAll(),
      context.read<RutaProvider>().fetchAll(),
      context.read<TurnoProvider>().fetchAll(),
    ]);
    if (mounted) setState(() => _loadingOptions = false);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleccione la fecha del turno',
    );
    if (selected != null && mounted) setState(() => _fecha = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final provider = context.read<AsignacionTurnoProvider>();
    final created = await provider.create(
      turnoId: _turnoId!,
      rutaId: _rutaId!,
      microId: _microId!,
      conductorId: _conductorId!,
      fecha: _formatDate(_fecha),
      observaciones: _observacionesController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asignación creada correctamente'),
          backgroundColor: AppTheme.activeGreen,
        ),
      );
      Navigator.pop(context, true);
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conductores = context.watch<ConductorProvider>().conductores;
    final micros = context.watch<MicroProvider>().micros;
    final rutas = context.watch<RutaProvider>().rutas;
    final turnos = context.watch<TurnoProvider>().turnos;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva asignación')),
      body: _loadingOptions
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Asignar turno a conductor',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Seleccione los recursos que participarán en el recorrido.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 20),
                    _dropdown<int>(
                      label: 'Conductor *',
                      value: _conductorId,
                      items: conductores
                          .where((item) => item.id != null && item.estado == 'activo')
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.nombreCompleto)))
                          .toList(),
                      onChanged: (value) => setState(() => _conductorId = value),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<int>(
                      label: 'Turno *',
                      value: _turnoId,
                      items: turnos
                          .where((item) => item.id != null && item.estado == 'activo')
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.displayNombre)))
                          .toList(),
                      onChanged: (value) => setState(() => _turnoId = value),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<int>(
                      label: 'Ruta *',
                      value: _rutaId,
                      items: rutas
                          .where((item) => item.id != null && item.estado == 'activo')
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.nombre)))
                          .toList(),
                      onChanged: (value) => setState(() => _rutaId = value),
                    ),
                    const SizedBox(height: 14),
                    _dropdown<int>(
                      label: 'Micro *',
                      value: _microId,
                      items: micros
                          .where((item) => item.id != null && item.estado == 'activo')
                          .map((item) => DropdownMenuItem(value: item.id, child: Text(item.placa)))
                          .toList(),
                      onChanged: (value) => setState(() => _microId = value),
                    ),
                    const SizedBox(height: 14),
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Fecha *'),
                      child: InkWell(
                        onTap: _selectDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(_fecha)),
                            const Icon(Icons.calendar_today, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Observaciones'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _save,
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_loading ? 'Guardando...' : 'Guardar asignación'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
      validator: (selected) => selected == null ? 'Campo requerido' : null,
    );
  }
}

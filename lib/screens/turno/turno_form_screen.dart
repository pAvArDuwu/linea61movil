import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/turno.dart';
import '../../providers/turno_provider.dart';
import '../../widgets/app_theme.dart';

class TurnoFormScreen extends StatefulWidget {
  final Turno? turno;
  const TurnoFormScreen({super.key, this.turno});
  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _fk = GlobalKey<FormState>();
  late TextEditingController _tipo, _inicio, _fin;
  bool _loading = false;
  bool get isEditing => widget.turno != null;

  @override
  void initState() { super.initState(); _tipo = TextEditingController(text: widget.turno?.tipo ?? ''); _inicio = TextEditingController(text: widget.turno?.horaInicio ?? ''); _fin = TextEditingController(text: widget.turno?.horaFin ?? ''); }
  @override
  void dispose() { _tipo.dispose(); _inicio.dispose(); _fin.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    final t = Turno(tipo: _tipo.text.trim(), horaInicio: _inicio.text.trim(), horaFin: _fin.text.trim());
    final prov = Provider.of<TurnoProvider>(context, listen: false);
    bool ok = isEditing ? await prov.update(widget.turno!.id!, t) : await prov.create(t);
    setState(() => _loading = false);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Turno actualizado' : 'Turno creado'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Turno' : 'Nuevo Turno')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.access_time, color: AppTheme.primary, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Editar Turno' : 'Nuevo Turno', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)), const Text('Complete los datos del turno', style: TextStyle(color: AppTheme.muted, fontSize: 13))])])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
            _f('Tipo *', _tipo, 'Ej: Mañana, Tarde, Noche', r: true),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _f('Hora Inicio *', _inicio, 'Ej: 06:00', r: true)), const SizedBox(width: 12), Expanded(child: _f('Hora Fin *', _fin, 'Ej: 14:00', r: true))]),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Cancelar')),
              Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)), child: ElevatedButton.icon(onPressed: _loading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18), label: Text(isEditing ? 'Actualizar' : 'Guardar')))])),
        ]))));
  }

  Widget _f(String l, TextEditingController c, String h, {bool r = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), TextFormField(controller: c, decoration: InputDecoration(hintText: h), validator: r ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null)]);
}

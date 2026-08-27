import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/interno.dart';
import '../../providers/interno_provider.dart';
import '../../widgets/app_theme.dart';

class InternoFormScreen extends StatefulWidget {
  final Interno? interno;
  const InternoFormScreen({super.key, this.interno});
  @override
  State<InternoFormScreen> createState() => _InternoFormScreenState();
}

class _InternoFormScreenState extends State<InternoFormScreen> {
  final _fk = GlobalKey<FormState>();
  late TextEditingController _numero, _fecha, _obs;
  String _estado = 'activo';
  bool _loading = false;
  bool get isEditing => widget.interno != null;

  @override
  void initState() { super.initState(); _numero = TextEditingController(text: widget.interno?.numeroInterno ?? ''); _fecha = TextEditingController(text: widget.interno?.fechaIngreso ?? ''); _obs = TextEditingController(text: widget.interno?.observaciones ?? ''); _estado = widget.interno?.estado ?? 'activo'; }
  @override
  void dispose() { _numero.dispose(); _fecha.dispose(); _obs.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    final i = Interno(numeroInterno: _numero.text.trim(), fechaIngreso: _fecha.text.trim().isEmpty ? null : _fecha.text.trim(), observaciones: _obs.text.trim().isEmpty ? null : _obs.text.trim(), estado: _estado);
    final prov = Provider.of<InternoProvider>(context, listen: false);
    bool ok = isEditing ? await prov.update(widget.interno!.id!, i) : await prov.create(i);
    setState(() => _loading = false);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Interno actualizado' : 'Interno creado'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Interno' : 'Nuevo Interno')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.dns, color: AppTheme.primary, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Editar Interno' : 'Nuevo Interno', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)), const Text('Complete los datos', style: TextStyle(color: AppTheme.muted, fontSize: 13))])])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
            _f('Número Interno *', _numero, 'Ej: 101', r: true, type: TextInputType.number),
            const SizedBox(height: 16),
            _f('Fecha de Ingreso', _fecha, 'YYYY-MM-DD'),
            const SizedBox(height: 16),
            _f('Observaciones', _obs, 'Observaciones...'),
            const SizedBox(height: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), DropdownButtonFormField<String>(value: _estado, decoration: const InputDecoration(), items: const [DropdownMenuItem(value: 'activo', child: Text('Activo')), DropdownMenuItem(value: 'inactivo', child: Text('Inactivo'))], onChanged: (v) => setState(() => _estado = v!))]),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Cancelar')),
              Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)), child: ElevatedButton.icon(onPressed: _loading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18), label: Text(isEditing ? 'Actualizar' : 'Guardar')))])),
        ]))));
  }

  Widget _f(String l, TextEditingController c, String h, {bool r = false, TextInputType type = TextInputType.text}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), TextFormField(controller: c, keyboardType: type, decoration: InputDecoration(hintText: h), validator: r ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null)]);
}

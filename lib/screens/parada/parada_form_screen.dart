import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/parada.dart';
import '../../providers/parada_provider.dart';
import '../../widgets/app_theme.dart';

class ParadaFormScreen extends StatefulWidget {
  final Parada? parada;
  const ParadaFormScreen({super.key, this.parada});
  @override
  State<ParadaFormScreen> createState() => _ParadaFormScreenState();
}

class _ParadaFormScreenState extends State<ParadaFormScreen> {
  final _fk = GlobalKey<FormState>();
  late TextEditingController _nombre, _ref, _lat, _lon;
  String _estado = 'activo';
  bool _loading = false;
  bool get isEditing => widget.parada != null;

  @override
  void initState() { super.initState(); _nombre = TextEditingController(text: widget.parada?.nombre ?? ''); _ref = TextEditingController(text: widget.parada?.referencia ?? ''); _lat = TextEditingController(text: widget.parada?.latitud?.toString() ?? ''); _lon = TextEditingController(text: widget.parada?.longitud?.toString() ?? ''); _estado = widget.parada?.estado ?? 'activo'; }
  @override
  void dispose() { _nombre.dispose(); _ref.dispose(); _lat.dispose(); _lon.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    final p = Parada(nombre: _nombre.text.trim(), referencia: _ref.text.trim().isEmpty ? null : _ref.text.trim(), latitud: double.tryParse(_lat.text), longitud: double.tryParse(_lon.text), estado: _estado);
    final prov = Provider.of<ParadaProvider>(context, listen: false);
    bool ok = isEditing ? await prov.update(widget.parada!.id!, p) : await prov.create(p);
    setState(() => _loading = false);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Parada actualizada' : 'Parada creada'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Parada' : 'Nueva Parada')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.location_on, color: AppTheme.accent, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Editar Parada' : 'Nueva Parada', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)), const Text('Complete los datos de la parada', style: TextStyle(color: AppTheme.muted, fontSize: 13))])])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
            _f('Nombre *', _nombre, 'Nombre de la parada', r: true),
            const SizedBox(height: 16), _f('Referencia', _ref, 'Punto de referencia'),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _f('Latitud', _lat, 'Ej: -17.78', type: const TextInputType.numberWithOptions(decimal: true, signed: true))), const SizedBox(width: 12), Expanded(child: _f('Longitud', _lon, 'Ej: -63.18', type: const TextInputType.numberWithOptions(decimal: true, signed: true)))]),
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

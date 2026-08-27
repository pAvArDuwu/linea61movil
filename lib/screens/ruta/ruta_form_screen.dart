import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ruta.dart';
import '../../providers/ruta_provider.dart';
import '../../widgets/app_theme.dart';

class RutaFormScreen extends StatefulWidget {
  final Ruta? ruta;
  const RutaFormScreen({super.key, this.ruta});
  @override
  State<RutaFormScreen> createState() => _RutaFormScreenState();
}

class _RutaFormScreenState extends State<RutaFormScreen> {
  final _fk = GlobalKey<FormState>();
  late TextEditingController _nombre, _desc, _sentido;
  String _estado = 'activo';
  bool _loading = false;
  bool get isEditing => widget.ruta != null;

  @override
  void initState() { super.initState(); _nombre = TextEditingController(text: widget.ruta?.nombre ?? ''); _desc = TextEditingController(text: widget.ruta?.descripcion ?? ''); _sentido = TextEditingController(text: widget.ruta?.sentido ?? ''); _estado = widget.ruta?.estado ?? 'activo'; }
  @override
  void dispose() { _nombre.dispose(); _desc.dispose(); _sentido.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    final r = Ruta(nombre: _nombre.text.trim(), descripcion: _desc.text.trim().isEmpty ? null : _desc.text.trim(), sentido: _sentido.text.trim().isEmpty ? null : _sentido.text.trim(), estado: _estado);
    final prov = Provider.of<RutaProvider>(context, listen: false);
    bool ok = isEditing ? await prov.update(widget.ruta!.id!, r) : await prov.create(r);
    setState(() => _loading = false);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Ruta actualizada' : 'Ruta creada'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Ruta' : 'Nueva Ruta')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.signpost, color: AppTheme.primary, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Editar Ruta' : 'Nueva Ruta', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)), const Text('Complete los datos de la ruta', style: TextStyle(color: AppTheme.muted, fontSize: 13))])])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
            _f('Nombre *', _nombre, 'Ej: Ruta 61', r: true),
            const SizedBox(height: 16), _f('Descripción', _desc, 'Descripción de la ruta'),
            const SizedBox(height: 16), _f('Sentido', _sentido, 'Ej: Ida / Vuelta'),
            const SizedBox(height: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), DropdownButtonFormField<String>(value: _estado, decoration: const InputDecoration(), items: const [DropdownMenuItem(value: 'activo', child: Text('Activo')), DropdownMenuItem(value: 'inactivo', child: Text('Inactivo'))], onChanged: (v) => setState(() => _estado = v!))]),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Cancelar')),
              Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)), child: ElevatedButton.icon(onPressed: _loading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18), label: Text(isEditing ? 'Actualizar' : 'Guardar')))])),
        ]))));
  }

  Widget _f(String l, TextEditingController c, String h, {bool r = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), TextFormField(controller: c, decoration: InputDecoration(hintText: h), validator: r ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null)]);
}

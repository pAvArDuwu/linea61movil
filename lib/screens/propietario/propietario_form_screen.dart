import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/propietario.dart';
import '../../providers/propietario_provider.dart';
import '../../widgets/app_theme.dart';

class PropietarioFormScreen extends StatefulWidget {
  final Propietario? propietario;
  const PropietarioFormScreen({super.key, this.propietario});
  @override
  State<PropietarioFormScreen> createState() => _PropietarioFormScreenState();
}

class _PropietarioFormScreenState extends State<PropietarioFormScreen> {
  final _fk = GlobalKey<FormState>();
  late TextEditingController _nombre, _apellido, _ci, _telefono, _correo;
  String _estado = 'activo';
  bool _loading = false;
  bool get isEditing => widget.propietario != null;

  @override
  void initState() { super.initState(); _nombre = TextEditingController(text: widget.propietario?.nombre ?? ''); _apellido = TextEditingController(text: widget.propietario?.apellido ?? ''); _ci = TextEditingController(text: widget.propietario?.ci ?? ''); _telefono = TextEditingController(text: widget.propietario?.telefono ?? ''); _correo = TextEditingController(text: widget.propietario?.correo ?? ''); _estado = widget.propietario?.estado ?? 'activo'; }
  @override
  void dispose() { _nombre.dispose(); _apellido.dispose(); _ci.dispose(); _telefono.dispose(); _correo.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _loading = true);
    final p = Propietario(nombre: _nombre.text.trim(), apellido: _apellido.text.trim(), ci: _ci.text.trim(), telefono: _telefono.text.trim(), correo: _correo.text.trim(), estado: _estado);
    final prov = Provider.of<PropietarioProvider>(context, listen: false);
    bool ok = isEditing ? await prov.update(widget.propietario!.id!, p) : await prov.create(p);
    setState(() => _loading = false);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Propietario actualizado' : 'Propietario creado'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); Navigator.pop(context, true); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Propietario' : 'Nuevo Propietario')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFDE8EC), Color(0xFFF8C4CE)]), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.contact_mail, color: AppTheme.accent, size: 20)), const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isEditing ? 'Editar Propietario' : 'Nuevo Propietario', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)), const Text('Complete los datos del propietario', style: TextStyle(color: AppTheme.muted, fontSize: 13))])])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _fk, child: Column(children: [
            Row(children: [Expanded(child: _f('Nombre *', _nombre, 'Nombre', r: true)), const SizedBox(width: 12), Expanded(child: _f('Apellido *', _apellido, 'Apellido', r: true))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _f('CI *', _ci, 'Carnet de identidad', r: true)), const SizedBox(width: 12), Expanded(child: _f('Teléfono', _telefono, 'Ej: 77712345', type: TextInputType.phone))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(flex: 2, child: _f('Correo Electrónico', _correo, 'correo@ejemplo.com', type: TextInputType.emailAddress)), const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), DropdownButtonFormField<String>(value: _estado, decoration: const InputDecoration(), items: const [DropdownMenuItem(value: 'activo', child: Text('Activo')), DropdownMenuItem(value: 'inactivo', child: Text('Inactivo'))], onChanged: (v) => setState(() => _estado = v!))]))]),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Cancelar')),
              Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
                child: ElevatedButton.icon(onPressed: _loading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent), icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18), label: Text(isEditing ? 'Actualizar' : 'Guardar'))),
            ])),
        ]))));
  }

  Widget _f(String label, TextEditingController c, String hint, {bool r = false, TextInputType type = TextInputType.text}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), TextFormField(controller: c, keyboardType: type, decoration: InputDecoration(hintText: hint), validator: r ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null)]);
}

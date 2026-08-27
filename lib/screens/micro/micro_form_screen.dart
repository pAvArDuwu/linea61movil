import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/micro.dart';
import '../../providers/micro_provider.dart';
import '../../providers/propietario_provider.dart';
import '../../providers/interno_provider.dart';
import '../../widgets/app_theme.dart';

class MicroFormScreen extends StatefulWidget {
  final Micro? micro;
  const MicroFormScreen({super.key, this.micro});
  @override
  State<MicroFormScreen> createState() => _MicroFormScreenState();
}

class _MicroFormScreenState extends State<MicroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placa, _marca, _modelo, _chasis, _anio, _capacidad;
  int? _propietarioId, _internoId;
  String _estado = 'activo';
  bool _isLoading = false;
  bool get isEditing => widget.micro != null;

  @override
  void initState() {
    super.initState();
    _placa = TextEditingController(text: widget.micro?.placa ?? '');
    _marca = TextEditingController(text: widget.micro?.marca ?? '');
    _modelo = TextEditingController(text: widget.micro?.modelo ?? '');
    _chasis = TextEditingController(text: widget.micro?.chasis ?? '');
    _anio = TextEditingController(text: widget.micro?.anioFabricacion?.toString() ?? '');
    _capacidad = TextEditingController(text: widget.micro?.capacidadPasajeros.toString() ?? '');
    _propietarioId = widget.micro?.propietarioId;
    _internoId = widget.micro?.internoId;
    _estado = widget.micro?.estado ?? 'activo';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropietarioProvider>(context, listen: false).fetchAll();
      Provider.of<InternoProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  void dispose() { _placa.dispose(); _marca.dispose(); _modelo.dispose(); _chasis.dispose(); _anio.dispose(); _capacidad.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final micro = Micro(placa: _placa.text.trim(), marca: _marca.text.trim(), modelo: _modelo.text.trim(), chasis: _chasis.text.trim().isEmpty ? null : _chasis.text.trim(), anioFabricacion: int.tryParse(_anio.text), capacidadPasajeros: int.tryParse(_capacidad.text) ?? 0, propietarioId: _propietarioId, internoId: _internoId, estado: _estado);
    final provider = Provider.of<MicroProvider>(context, listen: false);
    bool success = isEditing ? await provider.update(widget.micro!.id!, micro) : await provider.create(micro);
    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Micro actualizado' : 'Micro creado'), backgroundColor: AppTheme.activeGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: Text(isEditing ? 'Editar Micro' : 'Nuevo Micro')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.cardBorder))),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.directions_bus, color: Color(0xFFE65100), size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isEditing ? 'Editar Micro' : 'Nuevo Micro', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
                const Text('Complete los datos del vehículo', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
              ]),
            ])),
          Padding(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ASIGNACIONES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Consumer<PropietarioProvider>(builder: (_, prov, __) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Propietario *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(value: _propietarioId, decoration: const InputDecoration(hintText: 'Seleccione un propietario...'),
                  items: prov.propietarios.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.nombreCompleto} — CI: ${p.ci ?? ""}'))).toList(),
                  onChanged: (v) => setState(() => _propietarioId = v), validator: (v) => v == null ? 'Seleccione un propietario' : null),
              ]);
            }),
            const SizedBox(height: 12),
            Consumer<InternoProvider>(builder: (_, prov, __) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('N° Interno', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(value: _internoId, decoration: const InputDecoration(hintText: 'Sin interno asignado'),
                  items: [const DropdownMenuItem<int>(value: null, child: Text('Sin interno asignado')), ...prov.internos.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.numeroInterno} (${i.estado})')))],
                  onChanged: (v) => setState(() => _internoId = v)),
              ]);
            }),
            const Divider(height: 32),
            const Text('DATOS DEL VEHÍCULO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _field('Placa *', _placa, 'Ej: 1234-ABC', req: true)), const SizedBox(width: 12), Expanded(child: _field('Marca *', _marca, 'Ej: Toyota', req: true)), const SizedBox(width: 12), Expanded(child: _field('Modelo *', _modelo, 'Ej: Coaster', req: true))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _field('Chasis', _chasis, 'N° de chasis')), const SizedBox(width: 12), Expanded(child: _field('Año Fabricación', _anio, 'Ej: 2018', type: TextInputType.number)), const SizedBox(width: 12), Expanded(child: _field('Capacidad *', _capacidad, '30', req: true, type: TextInputType.number))]),
            const SizedBox(height: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: _estado, decoration: const InputDecoration(), items: const [DropdownMenuItem(value: 'activo', child: Text('Activo')), DropdownMenuItem(value: 'inactivo', child: Text('Inactivo'))], onChanged: (v) => setState(() => _estado = v!)),
            ]),
          ]))),
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.cardBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Cancelar')),
              Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))]),
                child: ElevatedButton.icon(onPressed: _isLoading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18),
                  label: Text(isEditing ? 'Actualizar' : 'Guardar Micro'))),
            ])),
        ]))),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool req = false, TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8),
      TextFormField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: hint), validator: req ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null),
    ]);
  }
}

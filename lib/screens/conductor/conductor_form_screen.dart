import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/conductor.dart';
import '../../providers/conductor_provider.dart';
import '../../widgets/app_theme.dart';

class ConductorFormScreen extends StatefulWidget {
  final Conductor? conductor;
  const ConductorFormScreen({super.key, this.conductor});

  @override
  State<ConductorFormScreen> createState() => _ConductorFormScreenState();
}

class _ConductorFormScreenState extends State<ConductorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombre;
  late TextEditingController _apellido;
  late TextEditingController _ci;
  late TextEditingController _telefono;
  late TextEditingController _correo;
  String _estado = 'activo';
  bool _isLoading = false;

  bool get isEditing => widget.conductor != null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.conductor?.nombre ?? '');
    _apellido = TextEditingController(text: widget.conductor?.apellido ?? '');
    _ci = TextEditingController(text: widget.conductor?.ci ?? '');
    _telefono = TextEditingController(text: widget.conductor?.telefono ?? '');
    _correo = TextEditingController(text: widget.conductor?.correo ?? '');
    _estado = widget.conductor?.estado ?? 'activo';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _ci.dispose();
    _telefono.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final conductor = Conductor(
      nombre: _nombre.text.trim(),
      apellido: _apellido.text.trim(),
      ci: _ci.text.trim(),
      telefono: _telefono.text.trim(),
      correo: _correo.text.trim(),
      estado: _estado,
    );

    final provider = Provider.of<ConductorProvider>(context, listen: false);
    bool success;
    if (isEditing) {
      success = await provider.update(widget.conductor!.id!, conductor);
    } else {
      success = await provider.create(conductor);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Conductor actualizado' : 'Conductor creado'),
          backgroundColor: AppTheme.activeGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Editar Conductor' : 'Nuevo Conductor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFDE8EC), Color(0xFFF8C4CE)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.badge, color: AppTheme.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditing ? 'Editar Conductor' : 'Nuevo Conductor', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primary)),
                        const Text('Complete los datos del conductor', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              // Form
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildField('Nombre *', _nombre, 'Nombre', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField('Apellido *', _apellido, 'Apellido', required: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildField('CI *', _ci, 'Carnet de identidad', required: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('Teléfono *', _telefono, 'Ej: 77712345', required: true, type: TextInputType.phone)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildField('Correo Electrónico *', _correo, 'correo@ejemplo.com', required: true, type: TextInputType.emailAddress),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _estado,
                                  decoration: const InputDecoration(),
                                  items: const [
                                    DropdownMenuItem(value: 'activo', child: Text('Activo')),
                                    DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                                  ],
                                  onChanged: (v) => setState(() => _estado = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.cardBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Cancelar'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        icon: _isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check, size: 18),
                        label: Text(isEditing ? 'Actualizar' : 'Guardar Conductor'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool required = false, TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(hintText: hint),
          validator: required ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null : null,
        ),
      ],
    );
  }
}

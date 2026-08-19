import '/backend/backend.dart';
import '/components/behavior_chip/behavior_chip_widget.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'behavioral_record_widget.dart' show BehavioralRecordWidget;
import 'package:flutter/material.dart';

/// Describes one selectable status option for a behavior type (e.g. "Bien",
/// "Se aisló"). Each behavior type defines its own small set of options so
/// the form stays specific without needing a different schema per type.
class BehaviorStatusOption {
  const BehaviorStatusOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Describes one behavior type's form: which status options it offers and
/// whether it also collects an optional quantity (hours, minutes, etc.).
/// Adding a new behavior type later only means adding an entry here.
class BehaviorTypeConfig {
  const BehaviorTypeConfig({
    required this.label,
    required this.icon,
    required this.statusOptions,
    this.quantityLabel,
    this.quantityHint,
    this.quantityUnit,
  });

  final String label;
  final IconData icon;
  final List<BehaviorStatusOption> statusOptions;

  /// Null means this behavior type doesn't collect a quantity.
  final String? quantityLabel;
  final String? quantityHint;
  final String? quantityUnit;
}

const List<BehaviorTypeConfig> kPredeterminedBehaviorTypes = [
  BehaviorTypeConfig(
    label: 'Sueño',
    icon: Icons.bed_rounded,
    statusOptions: [
      BehaviorStatusOption('Descansé bien', Icons.sentiment_satisfied_rounded),
      BehaviorStatusOption('Descansé regular', Icons.sentiment_neutral_rounded),
      BehaviorStatusOption(
          'Descansé mal', Icons.sentiment_dissatisfied_rounded),
    ],
    quantityLabel: 'Horas de sueño',
    quantityHint: 'Ej. 7',
    quantityUnit: 'h',
  ),
  BehaviorTypeConfig(
    label: 'Alimentación',
    icon: Icons.restaurant_rounded,
    statusOptions: [
      BehaviorStatusOption('Buena', Icons.sentiment_satisfied_rounded),
      BehaviorStatusOption('Regular', Icons.sentiment_neutral_rounded),
      BehaviorStatusOption('Mala', Icons.sentiment_dissatisfied_rounded),
    ],
  ),
  BehaviorTypeConfig(
    label: 'Socialización',
    icon: Icons.group_rounded,
    statusOptions: [
      BehaviorStatusOption('Socialicé', Icons.groups_rounded),
      BehaviorStatusOption(
          'Interacción limitada', Icons.person_outline_rounded),
      BehaviorStatusOption('Me aislé', Icons.person_off_rounded),
    ],
  ),
  BehaviorTypeConfig(
    label: 'Ejercicio',
    icon: Icons.self_improvement_rounded,
    statusOptions: [
      BehaviorStatusOption('Sí hice ejercicio', Icons.check_circle_rounded),
      BehaviorStatusOption('No hice ejercicio', Icons.cancel_rounded),
    ],
    quantityLabel: 'Duración',
    quantityHint: 'Ej. 30',
    quantityUnit: 'min',
  ),
  BehaviorTypeConfig(
    label: 'Trabajo/Estudio',
    icon: Icons.work_rounded,
    statusOptions: [
      BehaviorStatusOption('Cumplimiento alto', Icons.trending_up_rounded),
      BehaviorStatusOption('Cumplimiento medio', Icons.trending_flat_rounded),
      BehaviorStatusOption('Cumplimiento bajo', Icons.trending_down_rounded),
      BehaviorStatusOption('No realicé', Icons.remove_circle_outline_rounded),
    ],
    quantityLabel: 'Tiempo dedicado',
    quantityHint: 'Ej. 4',
    quantityUnit: 'h',
  ),
];

/// Generic fallback config used for custom behavior types the user adds.
BehaviorTypeConfig customBehaviorTypeConfig(String label) => BehaviorTypeConfig(
      label: label,
      icon: Icons.label_rounded,
      statusOptions: const [
        BehaviorStatusOption('Bien', Icons.sentiment_satisfied_rounded),
        BehaviorStatusOption('Regular', Icons.sentiment_neutral_rounded),
        BehaviorStatusOption('Mal', Icons.sentiment_dissatisfied_rounded),
      ],
      quantityLabel: 'Cantidad (opcional)',
      quantityHint: 'Ej. 2',
    );

class BehavioralRecordModel extends FlutterFlowModel<BehavioralRecordWidget> {
  ///  Local state fields for this page.

  // Conductas agregadas manualmente por el paciente (no predeterminadas).
  List<String> customBehaviorTypes = [];

  /// Agrega un tipo de conducta personalizado y lo selecciona automáticamente.
  /// Devuelve false si el nombre está vacío o ya existe (sin distinguir
  /// mayúsculas/minúsculas).
  bool addCustomBehaviorType(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return false;
    final alreadyExists = kPredeterminedBehaviorTypes
            .any((b) => b.label.toLowerCase() == trimmed.toLowerCase()) ||
        customBehaviorTypes
            .any((b) => b.toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;
    customBehaviorTypes.add(trimmed);
    selectedBehaviorType = trimmed;
    selectedValue = null;
    return true;
  }

  void removeCustomBehaviorType(String label) {
    customBehaviorTypes.remove(label);
    if (selectedBehaviorType == label) {
      selectedBehaviorType = null;
      selectedValue = null;
    }
  }

  String? selectedBehaviorType;
  String? selectedValue;

  BehaviorTypeConfig? get selectedConfig {
    final type = selectedBehaviorType;
    if (type == null) return null;
    for (final config in kPredeterminedBehaviorTypes) {
      if (config.label == type) return config;
    }
    return customBehaviorTypeConfig(type);
  }

  void selectBehaviorType(String type) {
    if (selectedBehaviorType == type) {
      selectedBehaviorType = null;
    } else {
      selectedBehaviorType = type;
    }
    selectedValue = null;
    quantityFieldModel.inputTextController?.clear();
    notesFieldModel.inputTextController?.clear();
  }

  bool isSaving = false;

  void resetForm() {
    selectedBehaviorType = null;
    selectedValue = null;
    customBehaviorTypes = [];
    quantityFieldModel.inputTextController?.clear();
    notesFieldModel.inputTextController?.clear();
  }

  ///  State fields for stateful widgets in this page.

  // Model for the quantity/duration TextField.
  late TextFieldModel quantityFieldModel;
  // Model for the notes TextField.
  late TextFieldModel notesFieldModel;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    quantityFieldModel = createModel(context, () => TextFieldModel());
    notesFieldModel = createModel(context, () => TextFieldModel());
    buttonModel = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    quantityFieldModel.dispose();
    notesFieldModel.dispose();
    buttonModel.dispose();
    bottomNavModel.dispose();
  }
}

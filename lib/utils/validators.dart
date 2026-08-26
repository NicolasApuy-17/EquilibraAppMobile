/// Validadores de entrada reutilizables para toda la app. Cada función es
/// pura (mismo resultado para la misma entrada, sin efectos secundarios,
/// salvo [validateGoalDate] que compara contra la fecha actual) y devuelve
/// `null` cuando el valor es válido o un mensaje de error en español listo
/// para mostrarse al usuario.
library validators;

/// Solo letras (incluye tildes y ñ) con espacios simples entre palabras.
/// Se valida sobre el texto ya recortado (`trim`), por lo que espacios al
/// inicio/fin no generan error por sí solos, pero dos o más espacios
/// seguidos entre palabras sí, porque el patrón exige exactamente uno.
final RegExp _fullNameRegex =
    RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$');

/// Mismo patrón usado en el resto del proyecto (FlutterFlow) para no tener
/// dos criterios de "correo válido" distintos conviviendo en la app.
/// https://stackoverflow.com/a/201378
const String kEmailRegexPattern =
    "^(?:[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])\$";

final RegExp _emailRegex = RegExp(kEmailRegexPattern);

/// Solo dígitos, espacios, guiones y un signo "+" (para el prefijo de país).
final RegExp _phoneAllowedCharsRegex = RegExp(r'^[0-9+\-\s]+$');

String? validateFullName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Ingresa tu nombre completo.';
  if (trimmed.length < 2) return 'El nombre debe tener al menos 2 caracteres.';
  if (trimmed.length > 60) return 'El nombre no puede superar los 60 caracteres.';
  if (!_fullNameRegex.hasMatch(trimmed)) {
    return 'El nombre solo puede contener letras y espacios (sin números ni símbolos).';
  }
  return null;
}

String? validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Ingresa tu correo electrónico.';
  if (!_emailRegex.hasMatch(trimmed)) {
    return 'Ingresa un correo electrónico válido.';
  }
  return null;
}

String? validatePassword(String? value) {
  final raw = value ?? '';
  if (raw.isEmpty) return 'Ingresa una contraseña.';
  if (raw.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';
  return null;
}

String? validatePasswordConfirmation(String? value, String original) {
  final raw = value ?? '';
  if (raw.isEmpty) return 'Confirma tu contraseña.';
  if (raw != original) return 'Las contraseñas no coinciden.';
  return null;
}

/// [required] es `false` por defecto porque el teléfono es opcional en la
/// mayoría de los flujos (p. ej. Editar Perfil); cuando se ingresa algo,
/// igual debe tener un formato válido.
String? validatePhone(String? value, {bool required = false}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'Ingresa tu número de teléfono.' : null;
  }
  if (!_phoneAllowedCharsRegex.hasMatch(trimmed)) {
    return 'El teléfono solo puede contener números, espacios, guiones y "+".';
  }
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length < 7 || digitsOnly.length > 15) {
    return 'Ingresa un teléfono válido (entre 7 y 15 dígitos).';
  }
  return null;
}

/// Acepta tanto "." como "," como separador decimal, igual que el resto de
/// la app al parsear estos campos antes de guardarlos en Firestore.
String? validateQuantity(String? value, {num? min, num? max, bool required = false}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'Ingresa una cantidad.' : null;
  }
  final parsed = num.tryParse(trimmed.replaceAll(',', '.'));
  if (parsed == null) {
    return 'Ingresa solo números.';
  }
  if (min != null && parsed < min) {
    return min == 0
        ? 'La cantidad no puede ser negativa.'
        : 'La cantidad mínima permitida es $min.';
  }
  if (max != null && parsed > max) {
    return 'La cantidad máxima permitida es $max.';
  }
  return null;
}

String? validateFreeText(
  String? value, {
  required int maxLength,
  bool required = true,
  String requiredMessage = 'Este campo es obligatorio.',
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? requiredMessage : null;
  }
  if (trimmed.length > maxLength) {
    return 'No puede superar los $maxLength caracteres.';
  }
  return null;
}

/// `null` es válido: la fecha objetivo es opcional. Cuando se elige una,
/// no puede quedar en el pasado (una meta con fecha vencida no tiene
/// sentido de negocio).
String? validateGoalDate(DateTime? value) {
  if (value == null) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(value.year, value.month, value.day);
  if (target.isBefore(today)) {
    return 'La fecha objetivo no puede ser anterior a hoy.';
  }
  return null;
}

/// Recorta y colapsa espacios internos repetidos a uno solo. Se usa antes
/// de persistir nombres para no guardar "María   José" con espacios extra.
String normalizeWhitespace(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Cualquier letra Unicode básica (con o sin tilde). Se usa para exigir que
/// una descripción libre tenga al menos algo de texto "con palabras" y no
/// sea solo un número o una cadena de símbolos.
final RegExp _hasLetterRegex = RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ]');

/// Para campos de texto libre que describen algo (la descripción de un
/// registro emocional, las notas de un registro de conducta): además de
/// longitud/obligatoriedad (ver [validateFreeText]), rechaza entradas que no
/// puedan ser una descripción real — solo dígitos/símbolos sin ninguna
/// letra, o un único carácter repetido ("aaaaaa", "......"). No exige una
/// oración completa ni prohíbe números dentro del texto (p. ej. "Dormí 7
/// horas" es válido); solo descarta los casos evidentemente sin sentido.
String? validateDescription(
  String? value, {
  required int maxLength,
  bool required = true,
  String requiredMessage = 'Este campo es obligatorio.',
}) {
  final lengthError = validateFreeText(
    value,
    maxLength: maxLength,
    required: required,
    requiredMessage: requiredMessage,
  );
  if (lengthError != null) return lengthError;

  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;

  if (!_hasLetterRegex.hasMatch(trimmed)) {
    return 'Escribe una descripción con palabras, no solo números o símbolos.';
  }

  final letters = trimmed.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ]'), '');
  if (letters.length < 3) {
    return 'Cuéntanos un poco más; es muy corto para tener sentido.';
  }

  final distinctLetters = letters.toLowerCase().split('').toSet();
  if (distinctLetters.length == 1) {
    return 'Esa descripción no parece tener sentido. Cuéntanos brevemente qué pasó.';
  }

  return null;
}

/// Para etiquetas cortas que el usuario escribe a mano (una emoción o una
/// conducta personalizada, p. ej. "Ansioso" o "Meditación"): deben leerse
/// como una palabra, no un número ni una cadena de símbolos. Reusa el mismo
/// patrón de letras que [validateFullName].
String? validateLabel(String? value, {int maxLength = 30}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Escribe un nombre.';
  if (trimmed.length < 2) return 'Debe tener al menos 2 caracteres.';
  if (trimmed.length > maxLength) {
    return 'No puede superar los $maxLength caracteres.';
  }
  if (!_fullNameRegex.hasMatch(trimmed)) {
    return 'Usa solo letras y espacios (sin números ni símbolos).';
  }
  return null;
}

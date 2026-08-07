const _monthNamesEs = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Formats a date as "d de <mes> de yyyy" without depending on intl's
/// locale-data initialization (which this app never calls).
String formatDateEs(DateTime date) =>
    '${date.day} de ${_monthNamesEs[date.month - 1]} de ${date.year}';

/// Formats a time as 24h "HH:mm".
String formatTime24(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

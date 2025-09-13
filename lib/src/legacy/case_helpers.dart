/// Capitalizes the first letter of [input].
///
/// Returns the input string with the first character in uppercase.
String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

/// Normalizes a raw type string to a Dart type.
///
/// Converts common type names (e.g., 'int', 'string', 'bool') to their Dart equivalents.
/// Handles lists and custom types as well.
String normalizeType(String raw) {
  final type = raw.trim().toLowerCase();

  switch (type) {
    case 'int':
      return 'int';
    case 'double':
    case 'float':
      return 'double';
    case 'bool':
    case 'boolean':
      return 'bool';
    case 'string':
      return 'String';
    case 'datetime':
    case 'date':
      return 'DateTime';
    default:
      // In case of List<T> or custom type
      if (type.startsWith('list<') && type.endsWith('>')) {
        final inner = type.substring(5, type.length - 1);
        return 'List<${normalizeType(inner)}>';
      }
      return capitalize(raw);
  }
}

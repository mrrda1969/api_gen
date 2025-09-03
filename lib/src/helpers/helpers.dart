import 'package:api_gen/src/defs/data_types.dart';

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

String normalizeType(String raw) {
  final type = raw.trim().toLowerCase();

  switch (type) {
    case 'integer':
    case 'int':
      return 'int';
    case 'number':
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
    case 'object':
      return 'Map<String, dynamic>';
    default:
      // In case of List<T> or custom type
      if (type.startsWith('list<') && type.endsWith('>')) {
        final inner = type.substring(5, type.length - 1);
        return 'List<${normalizeType(inner)}>';
      }
      return capitalize(raw);
  }
}

String resolveReference(String ref) {
  // Handle #/$defs/ModelName
  if (ref.startsWith('#/\$defs/')) {
    return ref.split('/').last;
  }

  // Handle #/definitions/ModelName (older style)
  if (ref.startsWith('#/definitions/')) {
    return ref.split('/').last;
  }

  // For external refs, return as-is for now
  return ref;
}

String getDartType(String jsonType, Map<String, dynamic> schema) {
  // Check for format first
  if (schema.containsKey('format')) {
    final format = schema['format'] as String;
    if (formatMapping.containsKey(format)) {
      return formatMapping[format]!;
    }
  }

  return typeMapping[jsonType] ?? 'dynamic';
}

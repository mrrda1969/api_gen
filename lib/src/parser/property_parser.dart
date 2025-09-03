import 'package:api_gen/src/defs/property_definition.dart';
import 'package:api_gen/src/helpers/helpers.dart';

PropertyDefinition parseProperty(
  String name,
  Map<String, dynamic> schema,
  bool isRequired,
) {
  String dartType;
  bool isNullable = false;

  // Handle references
  if (schema.containsKey('\$ref')) {
    dartType = resolveReference(schema['\$ref'] as String);
  }
  // Handle nullable types (type: ["string", "null"])
  else if (schema['type'] is List) {
    final types = schema['type'] as List;
    if (types.contains('null')) {
      isNullable = true;
      types.remove('null');
    }
    dartType = getDartType(types.first as String, schema);
  }
  // Handle regular types
  else {
    dartType = getDartType(schema['type'] as String? ?? 'object', schema);
  }

  // Handle arrays
  if (schema['type'] == 'array') {
    final items = schema['items'] as Map<String, dynamic>?;
    if (items != null) {
      if (items.containsKey('\$ref')) {
        final itemType = resolveReference(items['\$ref'] as String);
        dartType = 'List<$itemType>';
      } else {
        final itemType = getDartType(
          items['type'] as String? ?? 'dynamic',
          items,
        );
        dartType = 'List<$itemType>';
      }
    } else {
      dartType = 'List<dynamic>';
    }
  }

  // Handle enums
  if (schema.containsKey('enum')) {
    // For now, treat as String - could generate proper enums later
    dartType = 'String';
  }

  // Apply nullability
  if (isNullable || !isRequired) {
    dartType = '$dartType?';
  }

  return PropertyDefinition(
    name: name,
    dartType: dartType,
    isRequired: isRequired,
    isNullable: isNullable || !isRequired,
    enumValues: schema['enum'] as List<String>?,
  );
}

import 'package:api_gen/src/defs/model_definition.dart';
import 'package:api_gen/src/defs/property_definition.dart';
import 'package:api_gen/src/parser/property_parser.dart';

/// Parses a model from a JSON schema and returns a [ModelDefinition].
///
/// [name] is the model name.
/// [schema] is the model schema map.
ModelDefinition parseModel(String name, Map<String, dynamic> schema) {
  final properties = <PropertyDefinition>[];
  final requiredFields = Set<String>.from(schema['required'] ?? []);

  if (schema['type'] == 'object' && schema.containsKey('properties')) {
    final props = schema['properties'] as Map<String, dynamic>;

    for (final entry in props.entries) {
      final propName = entry.key;
      final propSchema = entry.value as Map<String, dynamic>;

      properties.add(
        parseProperty(propName, propSchema, requiredFields.contains(propName)),
      );
    }
  }

  return ModelDefinition(name: name, properties: properties);
}

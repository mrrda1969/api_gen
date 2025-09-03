import 'package:api_gen/src/defs/model_definition.dart';
import 'package:api_gen/src/helpers/helpers.dart';
import 'package:api_gen/src/parser/model_parser.dart';

Map<String, ModelDefinition> parseSchema(Map<String, dynamic> schema) {
  final models = <String, ModelDefinition>{};

  // Handle standard JSON Schema with $defs
  if (schema.containsKey('\$defs')) {
    final defs = schema['\$defs'] as Map<String, dynamic>;
    for (final entry in defs.entries) {
      final modelName = entry.key;
      final modelSchema = entry.value as Map<String, dynamic>;
      models[modelName] = parseModel(modelName, modelSchema);
    }
  }
  // Handle root-level definitions (older style)
  else if (schema.containsKey('definitions')) {
    final defs = schema['definitions'] as Map<String, dynamic>;
    for (final entry in defs.entries) {
      final modelName = entry.key;
      final modelSchema = entry.value as Map<String, dynamic>;
      models[modelName] = parseModel(modelName, modelSchema);
    }
  }
  // Handle direct object definitions
  else {
    for (final entry in schema.entries) {
      if (entry.key.startsWith('\$')) continue; // Skip schema metadata
      final modelName = capitalize(entry.key);
      final modelSchema = entry.value as Map<String, dynamic>;
      models[modelName] = parseModel(modelName, modelSchema);
    }
  }

  return models;
}

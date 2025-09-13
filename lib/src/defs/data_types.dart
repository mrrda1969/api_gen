/// Maps JSON schema types to Dart types.
const Map<String, String> typeMapping = {
  'string': 'String',
  'integer': 'int',
  'number': 'double',
  'boolean': 'bool',
  'array': 'List',
  'object': 'Map<String, dynamic>',
};

/// Maps JSON schema formats to Dart types.
const Map<String, String> formatMapping = {
  'date-time': 'DateTime',
  'date': 'DateTime',
  'email': 'String',
  'uri': 'String',
  'uuid': 'String',
};

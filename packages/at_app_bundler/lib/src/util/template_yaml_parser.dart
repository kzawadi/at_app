import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class TemplateYamlParser {
  Directory brick;
  late YamlMap yaml;

  TemplateYamlParser(this.brick);

  Future<Map<String, dynamic>> parse() async {
    File configFile = File(path.join(brick.absolute.path, 'template.yaml'));
    String fileContents = await configFile.readAsString();
    yaml = loadYamlDocument(fileContents).contents.value;

    Map<String, bool> env = _parseEnv();
    List<String> dependencies = _parseDependencies();
    Map<String, dynamic> android = _parsePlatformConfig('android');
    Map<String, String> envOverride = {};
    List<String> gitignore = _parseGitignore();

    if (env['override'] ?? false) {
      envOverride = _parseEnvOverride();
    }

    return {
      'env': env,
      'dependencies': dependencies,
      'android': android,
      'env_override': envOverride,
      'gitignore': gitignore,
    };
  }

  List<String> _parseDependencies() => _YamlMapParser<String, String?>(yaml['dependencies'])?.toLines() ?? [];

  Map<String, bool> _parseEnv() {
    Map<String, bool> parsed = _YamlMapParser<String, bool>(yaml['env'])?.toMap() ?? {};
    for (String key in ['include', 'gitignore', 'override']) {
      parsed[key] ??= false;
    }
    return parsed;
  }

  Map<String, dynamic> _parsePlatformConfig(String platform) =>
      _YamlMapParser<String, dynamic>(yaml[platform])?.toMap() ?? {};

  Map<String, String> _parseEnvOverride() => _YamlMapParser<String, String>(yaml['env_override'])?.toMap() ?? {};

  List<String> _parseGitignore() => _YamlListParser<String>(yaml['gitignore'])?.toList() ?? [];
}

extension _YamlMapParser<K, V> on YamlMap {
  Map<K, V> toMap() => Map<K, V>.from(this);

  List<String> toLines() {
    List<String> result = [];
    forEach((key, value) {
      result.add('$key: ${value ?? ''}');
    });
    return result;
  }
}

extension _YamlListParser<T> on YamlList {
  List<T> toList() => List<T>.from(this);
}

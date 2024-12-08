import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nebula_mesh_toolkit/src/generator.dart';
import 'package:nebula_mesh_toolkit/src/nebula_assets.dart';
import 'package:nebula_mesh_toolkit/src/network_template.dart';

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner('nebula_mesh_toolkit', 'Nebula mesh network toolkit.')
        ..addCommand(_GenerateArtifacts());
  await runner.run(arguments);
}

class _GenerateArtifacts extends Command {
  @override
  String get name => 'generate-artifacts';

  @override
  String get description =>
      'Generates nebula artifacts for each host based on the network template.';

  _GenerateArtifacts() {
    argParser
      ..addOption(
        'input',
        abbr: 'i',
        help: 'The input network template.',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output directory.',
        mandatory: true,
      )
      ..addOption(
        'github-asset-cache',
        help: 'The directory to use for caching GitHub assets.',
      );
  }

  Future<void> run() async {
    final input = argResults!['input'] as String;
    final output = argResults!['output'] as String;
    final githubAssetCache = argResults!['github-asset-cache'] as String?;

    final assets = GitHubNebulaAssets(cacheDir: githubAssetCache);

    final network = Network.fromYaml(await File(input).readAsString());
    await network.generateArtifacts(
      outputPath: output,
      assets: assets,
    );
  }
}

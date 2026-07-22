import 'dart:io';

Future<void> main(List<String> arguments) async {
  final candidates = <({String executable, List<String> prefix})>[
    (executable: 'python3', prefix: const <String>[]),
    (executable: 'python', prefix: const <String>[]),
    if (Platform.isWindows) (executable: 'py', prefix: const <String>['-3']),
  ];

  for (final candidate in candidates) {
    late final ProcessResult version;
    try {
      version = await Process.run(candidate.executable, <String>[
        ...candidate.prefix,
        '--version',
      ], runInShell: Platform.isWindows);
    } on ProcessException {
      continue;
    }
    if (version.exitCode != 0) {
      continue;
    }

    final process = await Process.start(
      candidate.executable,
      <String>[
        ...candidate.prefix,
        'tools/docs/check_docs.py',
        if (arguments.isEmpty) '.' else ...arguments,
      ],
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    exitCode = await process.exitCode;
    return;
  }

  stderr.writeln(
    'Python 3 executable not found. Install Python 3 and ensure python3, '
    'python, or py is available on PATH.',
  );
  exitCode = 127;
}

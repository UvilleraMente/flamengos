// Genera lib/l10n/cased_localizations.dart: un AppLocalizations que envuelve
// al real y transforma cada texto (MAYÚSCULAS, minúsculas, Tipo Título).
//
// Correr después de cambiar los .arb:
//   flutter gen-l10n && dart run tool/gen_text_case.dart
//
// Si falta alguna clave, el archivo generado no compila: así nunca se olvida.
import 'dart:io';

void main() {
  final source = File('lib/l10n/app_localizations.dart').readAsStringSync();
  final body = source.substring(
    source.indexOf('abstract class AppLocalizations'),
  );

  final member = RegExp(
    r'String\s+(?:get\s+(\w+)|(\w+)\s*\(([^)]*)\))\s*;',
    multiLine: true,
  );

  final out = StringBuffer()
    ..writeln('// GENERADO por tool/gen_text_case.dart — no editar a mano.')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln("import 'app_localizations.dart';")
    ..writeln()
    ..writeln(
      '/// Traducciones con el formato de letras elegido por el usuario.',
    )
    ..writeln('class CasedLocalizations extends AppLocalizations {')
    ..writeln('  CasedLocalizations(this._inner, this._transform)')
    ..writeln('    : super(_inner.localeName);')
    ..writeln()
    ..writeln('  final AppLocalizations _inner;')
    ..writeln('  final String Function(String) _transform;');

  var count = 0;
  for (final m in member.allMatches(body)) {
    count++;
    final getter = m.group(1);
    if (getter != null) {
      out
        ..writeln()
        ..writeln('  @override')
        ..writeln('  String get $getter => _transform(_inner.$getter);');
      continue;
    }
    final name = m.group(2)!;
    final params = m.group(3)!.trim();
    final names = params.isEmpty
        ? <String>[]
        : params
              .split(',')
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .map((p) => p.split(RegExp(r'\s+')).last)
              .toList();
    out
      ..writeln()
      ..writeln('  @override')
      ..writeln(
        '  String $name($params) => '
        '_transform(_inner.$name(${names.join(', ')}));',
      );
  }
  out.writeln('}');

  File('lib/l10n/cased_localizations.dart').writeAsStringSync(out.toString());
  stdout.writeln('cased_localizations.dart: $count textos');
}

// lib/services/curriculum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// A single RPC-style service that returns the entire curriculum hierarchy
/// in one nested JSON map: year -> subject -> strand -> sub-strand -> [outcomes]
class CurriculumService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the entire curriculum tree in one database call.
  /// The returned map has structure:
  /// {
  ///   "Year 1": {
  ///     "Mathematics": {
  ///       "Number and Algebra": {
  ///         "": [ { code, content_description, elaboration }, ... ],
  ///         "Sub-strand Name": [...]
  ///       },
  ///       ...
  ///     },
  ///     ...
  ///   },
  ///   ...
  /// }
  static Future<Map<String, dynamic>> getCurriculumTree() async {
    final rows = await _supabase
      .from('curriculum')
      .select('''
        level(name),
        subject(name),
        strand(name),
        sub_strand(name),
        code,
        content_description,
        elaboration
      ''')
      .order(
        'level,name,subject,name,strand,name,sub_strand,name,code'
      );

    final tree = <String, dynamic>{};
    for (final r in (rows as List)) {
      final year = r['level']['name'] as String;
      final subj = r['subject']['name'] as String;
      final str  = r['strand']['name'] as String;
      final sub  = (r['sub_strand']?['name'] as String?) ?? '';
      final outcome = {
        'code': r['code'],
        'content_description': r['content_description'],
        'elaboration': r['elaboration'],
      };

      tree
        .putIfAbsent(year, () => <String, dynamic>{})
        .putIfAbsent(subj, () => <String, dynamic>{})
        .putIfAbsent(str,  () => <String, dynamic>{})
        .putIfAbsent(sub,  () => <dynamic>[])  
        .add(outcome);
    }
    return tree;
  }
}

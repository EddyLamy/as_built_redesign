import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailyJournalServiceProvider = Provider<DailyJournalService>((ref) {
  return DailyJournalService();
});

final recentDailyJournalsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, projectId) {
  final service = ref.watch(dailyJournalServiceProvider);
  return service.watchRecentJournals(projectId);
});

class DailyJournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _documentToMap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {
      'id': doc.id,
      ...doc.data(),
    };
  }

  int _reportNoOf(Map<String, dynamic> journal) {
    return (journal['reportNo'] as num?)?.toInt() ?? 0;
  }

  DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  int _compareJournalPriority(
    Map<String, dynamic> left,
    Map<String, dynamic> right,
  ) {
    final leftUpdated = _timestampToDate(left['updatedAt']);
    final rightUpdated = _timestampToDate(right['updatedAt']);
    final updatedComparison = (leftUpdated ?? DateTime(1970))
        .compareTo(rightUpdated ?? DateTime(1970));
    if (updatedComparison != 0) {
      return updatedComparison;
    }

    return _reportNoOf(left).compareTo(_reportNoOf(right));
  }

  Map<String, dynamic> _mergeJournalMaps(List<Map<String, dynamic>> journals) {
    if (journals.isEmpty) {
      return <String, dynamic>{};
    }

    final ordered = List<Map<String, dynamic>>.from(journals)
      ..sort(_compareJournalPriority);
    final latest = ordered.last;
    final mergedRows = <Map<String, dynamic>>[];

    for (final journal in ordered) {
      final rows = (journal['siteWorkProgress'] as List<dynamic>? ?? const []);
      for (final row in rows) {
        if (row is Map<String, dynamic>) {
          mergedRows.add(Map<String, dynamic>.from(row));
        } else if (row is Map) {
          mergedRows.add(row.map(
            (key, value) => MapEntry(key.toString(), value),
          ));
        }
      }
    }

    return {
      ...latest,
      'duplicateCount': ordered.length,
      'siteWorkProgress': mergedRows,
      'remarks': ordered
          .map((journal) => (journal['remarks'] as String?)?.trim() ?? '')
          .where((value) => value.isNotEmpty)
          .fold<String>('', (_, value) => value),
    };
  }

  List<Map<String, dynamic>> _consolidateJournalMaps(
    List<Map<String, dynamic>> journals,
  ) {
    final journalsByDate = <String, List<Map<String, dynamic>>>{};

    for (final journal in journals) {
      final journalDate = _timestampToDate(journal['journalDate']);
      final journalDateKey =
          (journal['journalDateKey'] as String?)?.trim().isNotEmpty == true
              ? (journal['journalDateKey'] as String).trim()
              : _dateKey(journalDate ?? DateTime(1970));
      journalsByDate.putIfAbsent(journalDateKey, () => []).add(journal);
    }

    final consolidatedByDate =
        journalsByDate.values.map(_mergeJournalMaps).toList(growable: false)
          ..sort((left, right) {
            final leftDate = _timestampToDate(left['journalDate']);
            final rightDate = _timestampToDate(right['journalDate']);
            return (leftDate ?? DateTime(1970))
                .compareTo(rightDate ?? DateTime(1970));
          });

    final normalized = <Map<String, dynamic>>[];
    for (var index = 0; index < consolidatedByDate.length; index++) {
      normalized.add({
        ...consolidatedByDate[index],
        'reportNo': index + 1,
      });
    }

    normalized.sort((left, right) {
      final leftDate = _timestampToDate(left['journalDate']);
      final rightDate = _timestampToDate(right['journalDate']);
      return (rightDate ?? DateTime(1970))
          .compareTo(leftDate ?? DateTime(1970));
    });

    return normalized;
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  ({DateTime start, DateTime end}) _dayBounds(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return (start: start, end: start.add(const Duration(days: 1)));
  }

  Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value
          .map((key, nestedValue) => MapEntry(key.toString(), nestedValue));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _sanitizeWindMeasurements(dynamic value) {
    final rows = value as List<dynamic>? ?? const [];
    final sanitized = <Map<String, dynamic>>[];

    for (final row in rows) {
      final mapped = _normalizeMap(row);
      if (mapped.isEmpty) {
        continue;
      }

      mapped.remove('photoUrl');
      final timeLabel = (mapped['timeLabel'] as String?)?.trim() ?? '';
      if (timeLabel.isEmpty) {
        continue;
      }

      sanitized.add(mapped);
    }

    return sanitized;
  }

  bool _hasLegacyWindPhotoUrls(dynamic value) {
    final rows = value as List<dynamic>? ?? const [];
    for (final row in rows) {
      final mapped = _normalizeMap(row);
      if (mapped.containsKey('photoUrl')) {
        return true;
      }
    }
    return false;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _findJournalDocsByDate(
    String projectId,
    DateTime date,
  ) async {
    final dateKey = _dateKey(date);
    final bounds = _dayBounds(date);

    final keyedSnapshot = await _journalsRef(projectId)
        .where('journalDateKey', isEqualTo: dateKey)
        .get();

    final legacySnapshot = await _journalsRef(projectId)
        .where('journalDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(bounds.start))
        .where('journalDate', isLessThan: Timestamp.fromDate(bounds.end))
        .get();

    final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final doc in keyedSnapshot.docs) {
      docsById[doc.id] = doc;
    }
    for (final doc in legacySnapshot.docs) {
      docsById[doc.id] = doc;
    }

    return docsById.values.toList(growable: false);
  }

  DocumentReference<Map<String, dynamic>> _counterRef(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('counters')
        .doc('daily_journal');
  }

  CollectionReference<Map<String, dynamic>> _journalsRef(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('daily_journals');
  }

  Future<int> peekNextReportNumber(String projectId) async {
    final journals = await getAllJournals(projectId);
    return journals.length + 1;
  }

  Future<int> reserveNextReportNumber(String projectId) async {
    final counterReference = _counterRef(projectId);
    final snapshot = await counterReference.get();
    final current = (snapshot.data()?['lastReportNo'] as num?)?.toInt() ?? 0;
    final next = current + 1;

    await counterReference.set(
      {
        'lastReportNo': next,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return next;
  }

  Future<int> createJournal({
    required String projectId,
    required Map<String, dynamic> data,
  }) async {
    final sanitizedData = {
      ...data,
      if (data.containsKey('windMeasurements'))
        'windMeasurements': _sanitizeWindMeasurements(data['windMeasurements']),
    };

    final journalTimestamp = sanitizedData['journalDate'];
    if (journalTimestamp is! Timestamp) {
      throw Exception('journalDate inválido no Daily Journal.');
    }

    final journalDate = journalTimestamp.toDate();
    final journalDateKey = _dateKey(journalDate);
    final existingDocs = await _findJournalDocsByDate(projectId, journalDate);
    final normalizedJournals = await getAllJournals(projectId);
    final existingNormalizedJournal = normalizedJournals.where((journal) {
      final existingDate = _timestampToDate(journal['journalDate']);
      return existingDate != null && _dateKey(existingDate) == journalDateKey;
    }).firstOrNull;

    if (existingDocs.isNotEmpty) {
      final sortedExistingDocs = existingDocs.toList(growable: false)
        ..sort((left, right) => _compareJournalPriority(
              _documentToMap(left),
              _documentToMap(right),
            ));
      final existingDoc = sortedExistingDocs.last;
      final existingData = existingDoc.data();
      final reportNo =
          (existingNormalizedJournal?['reportNo'] as num?)?.toInt() ?? 1;
      final batch = _firestore.batch();

      batch.set(
          existingDoc.reference,
          {
            ...sanitizedData,
            'projectId': projectId,
            'journalDateKey': journalDateKey,
            'reportNo': reportNo,
            'createdAt':
                existingData['createdAt'] ?? FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      for (final duplicateDoc
          in sortedExistingDocs.take(sortedExistingDocs.length - 1)) {
        batch.delete(duplicateDoc.reference);
      }

      await batch.commit();

      return reportNo;
    }

    final counterReference = _counterRef(projectId);
    final reportNo = normalizedJournals.length + 1;
    final journalReference = _journalsRef(projectId).doc();
    final batch = _firestore.batch();

    batch.set(
      counterReference,
      {
        'lastReportNo': reportNo,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(journalReference, {
      ...sanitizedData,
      'reportNo': reportNo,
      'projectId': projectId,
      'journalDateKey': journalDateKey,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    final savedSnapshot = await journalReference.get();
    if (!savedSnapshot.exists) {
      throw Exception('O Daily Journal não ficou persistido após o save.');
    }

    return reportNo;
  }

  Future<Map<String, dynamic>?> getLatestJournal(String projectId) async {
    final journals = await getAllJournals(projectId);
    if (journals.isEmpty) {
      return null;
    }

    return journals.first;
  }

  Future<Map<String, dynamic>?> getJournalByDate(
    String projectId,
    DateTime date,
  ) async {
    final docs = await _findJournalDocsByDate(projectId, date);

    if (docs.isEmpty) {
      return null;
    }

    final mergedJournal = _mergeJournalMaps(
      docs.map(_documentToMap).toList(growable: false),
    );
    final normalizedJournals = await getAllJournals(projectId);
    final normalizedReportNo = normalizedJournals
        .where((journal) {
          final journalDate = _timestampToDate(journal['journalDate']);
          return journalDate != null && _dateKey(journalDate) == _dateKey(date);
        })
        .map((journal) => (journal['reportNo'] as num?)?.toInt() ?? 0)
        .cast<int?>()
        .firstOrNull;

    return {
      ...mergedJournal,
      if (normalizedReportNo != null && normalizedReportNo > 0)
        'reportNo': normalizedReportNo,
    };
  }

  Future<List<Map<String, dynamic>>> getAllJournals(String projectId) async {
    final snapshot = await _journalsRef(projectId)
        .orderBy('journalDate', descending: false)
        .get();
    return _consolidateJournalMaps(
      snapshot.docs.map(_documentToMap).toList(growable: false),
    );
  }

  Future<int> deleteJournalByDate(String projectId, DateTime date) async {
    final docs = await _findJournalDocsByDate(projectId, date);

    if (docs.isEmpty) {
      return 0;
    }

    final batch = _firestore.batch();
    for (final doc in docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return docs.length;
  }

  Future<int> cleanupLegacyWindMeasurementPhotos(String projectId) async {
    final snapshot = await _journalsRef(projectId).get();

    var updatedCount = 0;
    var pendingOperations = 0;
    var batch = _firestore.batch();

    Future<void> commitBatchIfNeeded({bool force = false}) async {
      if (pendingOperations == 0) {
        return;
      }

      if (force || pendingOperations >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        pendingOperations = 0;
      }
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final windMeasurements = data['windMeasurements'];
      if (!_hasLegacyWindPhotoUrls(windMeasurements)) {
        continue;
      }

      batch.update(doc.reference, {
        'windMeasurements': _sanitizeWindMeasurements(windMeasurements),
      });
      pendingOperations += 1;
      updatedCount += 1;

      await commitBatchIfNeeded();
    }

    await commitBatchIfNeeded(force: true);
    return updatedCount;
  }

  Stream<List<Map<String, dynamic>>> watchRecentJournals(String projectId) {
    return _journalsRef(projectId)
        .orderBy('journalDate', descending: true)
        .snapshots()
        .map((snapshot) => _consolidateJournalMaps(
              snapshot.docs.map(_documentToMap).toList(growable: false),
            ).take(5).toList(growable: false));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AshaTriageStatus {
  stable,
  monitor,
  needsAttention,
}

extension AshaTriageStatusX on AshaTriageStatus {
  String get label {
    switch (this) {
      case AshaTriageStatus.stable:
        return 'Stable';
      case AshaTriageStatus.monitor:
        return 'Monitor';
      case AshaTriageStatus.needsAttention:
        return 'Needs Attention';
    }
  }

  Color get color {
    switch (this) {
      case AshaTriageStatus.stable:
        return const Color(0xFF10B981);
      case AshaTriageStatus.monitor:
        return const Color(0xFFF59E0B);
      case AshaTriageStatus.needsAttention:
        return const Color(0xFFEF4444);
    }
  }

  Color get bgColor {
    switch (this) {
      case AshaTriageStatus.stable:
        return const Color(0xFFECFDF5);
      case AshaTriageStatus.monitor:
        return const Color(0xFFFFFBEB);
      case AshaTriageStatus.needsAttention:
        return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case AshaTriageStatus.stable:
        return Icons.check_circle_rounded;
      case AshaTriageStatus.monitor:
        return Icons.warning_rounded;
      case AshaTriageStatus.needsAttention:
        return Icons.error_rounded;
    }
  }
}

class AshaPatientRecord {
  final String id;
  final String name;
  final int age;
  final String village;
  final String district;
  final String state;
  final String language;
  final String phone;
  final String caregiverName;
  final AshaTriageStatus status;
  final int score;
  final int durationSec;
  final String trendNote;
  final List<String> notes;
  final String? nextVisitDate;

  const AshaPatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.village,
    required this.district,
    required this.state,
    required this.language,
    required this.phone,
    required this.caregiverName,
    required this.status,
    required this.score,
    required this.durationSec,
    required this.trendNote,
    this.notes = const [],
    this.nextVisitDate,
  });

  AshaPatientRecord copyWith({
    String? id,
    String? name,
    int? age,
    String? village,
    String? district,
    String? state,
    String? language,
    String? phone,
    String? caregiverName,
    AshaTriageStatus? status,
    int? score,
    int durationSec = 38,
    String? trendNote,
    List<String>? notes,
    String? nextVisitDate,
  }) {
    return AshaPatientRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      language: language ?? this.language,
      phone: phone ?? this.phone,
      caregiverName: caregiverName ?? this.caregiverName,
      status: status ?? this.status,
      score: score ?? this.score,
      durationSec: durationSec,
      trendNote: trendNote ?? this.trendNote,
      notes: notes ?? this.notes,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
    );
  }
}

class AshaPatientNotifier extends StateNotifier<List<AshaPatientRecord>> {
  AshaPatientNotifier()
      : super(const [
          AshaPatientRecord(
            id: 'PAT-101',
            name: 'Ramesh Das',
            age: 72,
            village: 'Rampur Gaon',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543211',
            caregiverName: 'Suresh Das (Son)',
            status: AshaTriageStatus.needsAttention,
            score: 5,
            durationSec: 54,
            trendNote: 'Performance mein mahatvapurn girawat dikhi hai. ASHA review avashyak hai.',
            notes: ['Recent confusion regarding morning medicine.', 'Needs follow-up with PHC Medical Officer.'],
            nextVisitDate: 'Tomorrow at 10:00 AM',
          ),
          AshaPatientRecord(
            id: 'PAT-102',
            name: 'Lakshmi Tai',
            age: 68,
            village: 'Dhor Kola',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543212',
            caregiverName: 'Pooja (Daughter)',
            status: AshaTriageStatus.monitor,
            score: 7,
            durationSec: 42,
            trendNote: 'Halke parivartan dikhe hain. Niyamit nazar rakhein.',
            notes: ['Practicing memory games daily with granddaughter.'],
            nextVisitDate: 'Friday, 11:30 AM',
          ),
          AshaPatientRecord(
            id: 'PAT-103',
            name: 'Haren Roy',
            age: 69,
            village: 'Sonapur',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543213',
            caregiverName: 'Anjali (Wife)',
            status: AshaTriageStatus.stable,
            score: 9,
            durationSec: 32,
            trendNote: 'Sab kuch theek hai. Regular practice jaari rakhein.',
            notes: ['Active in morning walks, stable cognitive score.'],
            nextVisitDate: 'Next Week',
          ),
          AshaPatientRecord(
            id: 'PAT-104',
            name: 'Kamla Devi',
            age: 74,
            village: 'Rampur Gaon',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543214',
            caregiverName: 'Vikas (Son)',
            status: AshaTriageStatus.monitor,
            score: 6,
            durationSec: 48,
            trendNote: 'Mild memory lapse during sound recognition.',
            notes: ['Regular blood pressure check advised.'],
            nextVisitDate: 'Monday, 2:00 PM',
          ),
          AshaPatientRecord(
            id: 'PAT-105',
            name: 'Dinanath Sharma',
            age: 78,
            village: 'Sonapur',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543215',
            caregiverName: 'Rohan Sharma',
            status: AshaTriageStatus.stable,
            score: 9,
            durationSec: 30,
            trendNote: 'High engagement and sharp pattern recall.',
            notes: ['Loves daily story and devotional sessions.'],
            nextVisitDate: 'Next Thursday',
          ),
        ]);

  void addPatient(AshaPatientRecord patient) {
    state = [patient, ...state];
  }

  void updatePatient(AshaPatientRecord updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }

  void addNote(String patientId, String note) {
    state = [
      for (final p in state)
        if (p.id == patientId) p.copyWith(notes: [...p.notes, note]) else p,
    ];
  }
}

final ashaPatientsProvider =
    StateNotifierProvider<AshaPatientNotifier, List<AshaPatientRecord>>((ref) {
  return AshaPatientNotifier();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String relationHi;
  final IconData icon;
  final Color avatarColor;
  final String? photoUrl;
  final String? voiceClipText;
  final String memoryNote;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.relationHi,
    required this.icon,
    required this.avatarColor,
    this.photoUrl,
    this.voiceClipText,
    required this.memoryNote,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    String? relation,
    String? relationHi,
    IconData? icon,
    Color? avatarColor,
    String? photoUrl,
    String? voiceClipText,
    String? memoryNote,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      relationHi: relationHi ?? this.relationHi,
      icon: icon ?? this.icon,
      avatarColor: avatarColor ?? this.avatarColor,
      photoUrl: photoUrl ?? this.photoUrl,
      voiceClipText: voiceClipText ?? this.voiceClipText,
      memoryNote: memoryNote ?? this.memoryNote,
    );
  }
}

class FamilyMembersNotifier extends StateNotifier<List<FamilyMember>> {
  FamilyMembersNotifier()
      : super(const [
          FamilyMember(
            id: 'fam-1',
            name: 'रोहन (Rohan)',
            relation: 'Son (बेटा)',
            relationHi: 'बेटा',
            icon: Icons.face,
            avatarColor: Color(0xFF2563EB),
            memoryNote: 'हर शाम 7 बजे फोन करता है और दवा याद दिलाता है।',
            voiceClipText: 'पापा, नमस्ते! अपनी शाम की दवाई समय पर ले लीजियेगा।',
          ),
          FamilyMember(
            id: 'fam-2',
            name: 'पूजा (Pooja)',
            relation: 'Daughter (बेटी)',
            relationHi: 'बेटी',
            icon: Icons.face_3,
            avatarColor: Color(0xFF9333EA),
            memoryNote: 'हर रविवार को घर आकर नाश्ता बनाती है।',
            voiceClipText: 'पापा, मैं रविवार को आपकी पसंदीदा खीर लेकर आऊंगी।',
          ),
          FamilyMember(
            id: 'fam-3',
            name: 'आरव (Aarav)',
            relation: 'Grandson (पोता)',
            relationHi: 'पोता',
            icon: Icons.child_care,
            avatarColor: Color(0xFF16A34A),
            memoryNote: 'कक्षा 4 में पढ़ता है, आपके साथ कैरम खेलता है।',
            voiceClipText: 'दादाजी, स्कूल के बाद हम साथ में कहानी सुनेंगे!',
          ),
          FamilyMember(
            id: 'fam-4',
            name: 'सुमन (Suman)',
            relation: 'Wife (पत्नी / जीवनसाथी)',
            relationHi: 'पत्नी',
            icon: Icons.favorite,
            avatarColor: Color(0xFFE11D48),
            memoryNote: 'सुबह की चाय और बागवानी साथ में करते हैं।',
            voiceClipText: 'सुप्रभात! चलिए आज तुलसी के पौधे में पानी देते हैं।',
          ),
        ]);

  void addFamilyMember(FamilyMember member) {
    state = [...state, member];
  }

  void updateFamilyMember(FamilyMember updated) {
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }

  void removeFamilyMember(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final familyMembersProvider =
    StateNotifierProvider<FamilyMembersNotifier, List<FamilyMember>>((ref) {
  return FamilyMembersNotifier();
});

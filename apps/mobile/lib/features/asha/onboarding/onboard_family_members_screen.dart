import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/family_members_service.dart';

class OnboardFamilyMembersScreen extends ConsumerStatefulWidget {
  const OnboardFamilyMembersScreen({super.key, this.prevData});
  final Map<String, dynamic>? prevData;

  @override
  ConsumerState<OnboardFamilyMembersScreen> createState() => _OnboardFamilyMembersScreenState();
}

class _OnboardFamilyMembersScreenState extends ConsumerState<OnboardFamilyMembersScreen> {
  // Preset photo choices for quick selection
  static const List<Map<String, String>> _photoPresets = [
    {'label': 'Son (बेटा)', 'path': 'assets/images/family/son.jpg'},
    {'label': 'Daughter (बेटी)', 'path': 'assets/images/family/daughter.jpg'},
    {'label': 'Grandson (पोता)', 'path': 'assets/images/family/grandson.jpg'},
    {'label': 'Wife (पत्नी)', 'path': 'assets/images/family/wife.jpg'},
    {'label': 'Brother (भाई)', 'path': 'assets/images/family/brother.jpg'},
    {'label': 'Sister (बहन)', 'path': 'assets/images/family/sister.jpg'},
  ];

  static const List<String> _relations = [
    'Son (बेटा)',
    'Daughter (बेटी)',
    'Grandson (पोता)',
    'Granddaughter (पोती)',
    'Wife (पत्नी)',
    'Husband (पति)',
    'Brother (भाई)',
    'Sister (बहन)',
    'Mother (माँ)',
    'Father (पिता)',
    'Caregiver (देखभालकर्ता)',
  ];

  // 6 compulsory member slots
  late List<TextEditingController> _nameControllers;
  late List<String> _selectedRelations;
  late List<String> _selectedPhotos;

  @override
  void initState() {
    super.initState();
    _nameControllers = List.generate(
      6,
      (i) => TextEditingController(
        text: i == 0
            ? 'रोहन (Rohan)'
            : i == 1
                ? 'पूजा (Pooja)'
                : i == 2
                    ? 'आरव (Aarav)'
                    : i == 3
                        ? 'सुमन (Suman)'
                        : i == 4
                            ? 'मोहन (Mohan)'
                            : 'सुनीता (Sunita)',
      ),
    );
    _selectedRelations = [
      'Son (बेटा)',
      'Daughter (बेटी)',
      'Grandson (पोता)',
      'Wife (पत्नी)',
      'Brother (भाई)',
      'Sister (बहन)',
    ];
    _selectedPhotos = [
      'assets/images/family/son.jpg',
      'assets/images/family/daughter.jpg',
      'assets/images/family/grandson.jpg',
      'assets/images/family/wife.jpg',
      'assets/images/family/brother.jpg',
      'assets/images/family/sister.jpg',
    ];
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isAllValid {
    for (int i = 0; i < 6; i++) {
      if (_nameControllers[i].text.trim().isEmpty || _selectedPhotos[i].isEmpty) {
        return false;
      }
    }
    return true;
  }

  int get _validCount {
    int count = 0;
    for (int i = 0; i < 6; i++) {
      if (_nameControllers[i].text.trim().isNotEmpty && _selectedPhotos[i].isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  void _pickPhoto(int slotIndex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Photo for Member ${slotIndex + 1} (सदस्य ${slotIndex + 1} की फोटो चुनें)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _photoPresets.length,
              itemBuilder: (ctx, idx) {
                final preset = _photoPresets[idx];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPhotos[slotIndex] = preset['path']!;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedPhotos[slotIndex] == preset['path']
                            ? const Color(0xFF059669)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Image.asset(preset['path']!, fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            preset['label']!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (!_isAllValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया परिवार के सभी 6 सदस्यों का नाम और फोटो भरें (All 6 members required).'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Build 6 FamilyMember instances
    final List<FamilyMember> members = [];
    for (int i = 0; i < 6; i++) {
      final name = _nameControllers[i].text.trim();
      final relation = _selectedRelations[i];
      final photo = _selectedPhotos[i];
      final relHi = relation.contains('(') ? relation.split('(')[1].replaceAll(')', '') : relation;

      members.add(
        FamilyMember(
          id: 'fam-${i + 1}',
          name: name,
          relation: relation,
          relationHi: relHi,
          icon: Icons.face,
          avatarColor: i % 2 == 0 ? const Color(0xFF059669) : const Color(0xFF2563EB),
          photoPath: photo,
          memoryNote: 'Registered during ASHA onboarding.',
        ),
      );
    }

    // Update global state provider
    ref.read(familyMembersProvider.notifier).setFamilyMembers(members);

    final mergedData = {
      ...?widget.prevData,
      'familyMembers': members,
    };

    context.push('/asha/onboard/step3', extra: mergedData);
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Step 3 of 4: Pariwar ke Sadasya',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header title & counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'परिवार के 6 सदस्य जोड़ें',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark),
                            ),
                            Text(
                              'Family Match Game ke liye compulsory hai',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isAllValid ? emeraldBrand.withOpacity(0.15) : Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isAllValid ? emeraldBrand : Colors.amber.shade700,
                            ),
                          ),
                          child: Text(
                            '$_validCount / 6 Added',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _isAllValid ? emeraldBrand : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 6 Compulsory Family Member Slots
                    ...List.generate(6, (index) {
                      final isFilled =
                          _nameControllers[index].text.trim().isNotEmpty && _selectedPhotos[index].isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isFilled ? emeraldBrand.withOpacity(0.5) : Colors.grey.shade300,
                            width: isFilled ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Photo Selector Avatar
                            GestureDetector(
                              onTap: () => _pickPhoto(index),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      _selectedPhotos[index],
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: emeraldBrand,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Inputs: Name & Relation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Member ${index + 1} *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isFilled)
                                        const Icon(Icons.check_circle_rounded, color: emeraldBrand, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _nameControllers[index],
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: 'Naam enter karein (e.g. रोहन)',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _selectedRelations[index],
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: const TextStyle(fontSize: 13, color: textDark, fontWeight: FontWeight.w600),
                                    items: _relations
                                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedRelations[index] = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isAllValid ? _handleNext : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAllValid ? emeraldBrand : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isAllValid ? 'Aage Badhein (Confirm 6 Members)' : '6 Sadasya Poore Karein ($_validCount/6)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

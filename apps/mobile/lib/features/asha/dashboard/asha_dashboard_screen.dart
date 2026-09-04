import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/asha_auth_service.dart';
import '../patients/asha_patient_repository.dart';

class AshaDashboardScreen extends ConsumerStatefulWidget {
  const AshaDashboardScreen({super.key});

  @override
  ConsumerState<AshaDashboardScreen> createState() => _AshaDashboardScreenState();
}

class _AshaDashboardScreenState extends ConsumerState<AshaDashboardScreen> {
  String _searchQuery = '';
  AshaTriageStatus? _filterStatus;
  int _currentNavIndex = 1; // Default to 'Patients'

  @override
  Widget build(BuildContext context) {
    final ashaAuth = ref.watch(ashaAuthProvider);
    final allPatients = ref.watch(ashaPatientsProvider);

    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    final filteredPatients = allPatients.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.village.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || p.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    final stableCount = allPatients.where((p) => p.status == AshaTriageStatus.stable).length;
    final monitorCount = allPatients.where((p) => p.status == AshaTriageStatus.monitor).length;
    final attentionCount = allPatients.where((p) => p.status == AshaTriageStatus.needsAttention).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.spa, color: emeraldBrand),
          ),
        ),
        title: const Text(
          'Mere Buzurg',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: emeraldBrand, size: 28),
            tooltip: 'Naya Buzurg Jodein',
            onPressed: () => context.push('/asha/onboard'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 24),
            tooltip: 'Logout ASHA',
            onPressed: () {
              ref.read(ashaAuthProvider.notifier).logout();
              context.go('/asha/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Naam ya gaon se dhundhein...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Filter Tabs Row: All, Stable, Monitor, Needs Attention
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('All (${allPatients.length})', isSelected: _filterStatus == null, onTap: () {
                      setState(() => _filterStatus = null);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterPill('Stable ($stableCount)',
                        color: const Color(0xFF10B981),
                        isSelected: _filterStatus == AshaTriageStatus.stable, onTap: () {
                      setState(() => _filterStatus = AshaTriageStatus.stable);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterPill('Monitor ($monitorCount)',
                        color: const Color(0xFFF59E0B),
                        isSelected: _filterStatus == AshaTriageStatus.monitor, onTap: () {
                      setState(() => _filterStatus = AshaTriageStatus.monitor);
                    }),
                    const SizedBox(width: 8),
                    _buildFilterPill('Needs Attention ($attentionCount)',
                        color: const Color(0xFFEF4444),
                        isSelected: _filterStatus == AshaTriageStatus.needsAttention, onTap: () {
                      setState(() => _filterStatus = AshaTriageStatus.needsAttention);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Patient List
              Expanded(
                child: filteredPatients.isEmpty
                    ? const Center(child: Text('No patients found.'))
                    : ListView.separated(
                        itemCount: filteredPatients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = filteredPatients[index];

                          return InkWell(
                            onTap: () {
                              context.push('/asha/action/${p.id}', extra: p);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: p.status == AshaTriageStatus.needsAttention
                                      ? const Color(0xFFFECDD3)
                                      : const Color(0xFFE2E8F0),
                                  width: p.status == AshaTriageStatus.needsAttention ? 1.5 : 1,
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
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: p.status.bgColor,
                                    child: Text(
                                      p.name.contains('Lakshmi') || p.name.contains('Kamla')
                                          ? '👵'
                                          : '👴',
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${p.age} saal | ${p.village}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.status.bgColor,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                                color: p.status.color.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            p.status.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: p.status.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    p.status.icon,
                                    color: p.status.color,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.group_rounded, 'Patients'),
                _buildNavItem(2, Icons.calendar_month_rounded, 'Visits'),
                _buildNavItem(3, Icons.notifications_active_rounded, 'Alerts'),
                _buildNavItem(4, Icons.more_horiz_rounded, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    String label, {
    Color color = const Color(0xFF059669),
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    const emeraldBrand = Color(0xFF059669);
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 0) {
          context.go('/asha/dashboard');
        } else if (index == 2 || index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $label...')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? emeraldBrand : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? emeraldBrand : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

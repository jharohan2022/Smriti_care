import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/asha_auth_service.dart';
import '../patients/asha_patient_repository.dart';

class AshaDashboardScreen extends ConsumerStatefulWidget {
  final int initialNavIndex;
  const AshaDashboardScreen({super.key, this.initialNavIndex = 0});

  @override
  ConsumerState<AshaDashboardScreen> createState() => _AshaDashboardScreenState();
}

class _AshaDashboardScreenState extends ConsumerState<AshaDashboardScreen> {
  // Navigation: 0=Home, 1=Patients, 2=Visits, 3=Alerts, 4=More
  late int _currentNavIndex;

  // Patients Tab State
  String _searchQuery = '';
  AshaTriageStatus? _filterStatus;

  // Visits Tab State
  String _visitFilter = 'Aaj';
  final List<Map<String, dynamic>> _visitsList = [
    {
      'id': 'V-1',
      'patientId': 'PAT-101',
      'name': 'Ramesh Das',
      'age': 72,
      'village': 'Rampur Gaon, Ward 2',
      'time': '10:30 AM',
      'purpose': 'Dementia recall test & medicine review',
      'status': 'Pending',
      'priority': 'High',
      'dateCategory': 'Aaj',
      'phone': '9876543211',
    },
    {
      'id': 'V-2',
      'patientId': 'PAT-104',
      'name': 'Kamla Devi',
      'age': 74,
      'village': 'Rampur Gaon, Ward 4',
      'time': '02:00 PM',
      'purpose': 'Blood pressure check & cognitive game followup',
      'status': 'Pending',
      'priority': 'Medium',
      'dateCategory': 'Aaj',
      'phone': '9876543214',
    },
    {
      'id': 'V-3',
      'patientId': 'PAT-102',
      'name': 'Lakshmi Tai',
      'age': 68,
      'village': 'Dhor Kola',
      'time': '04:30 PM',
      'purpose': 'Caregiver counselling & daily exercise review',
      'status': 'Pending',
      'priority': 'Normal',
      'dateCategory': 'Aaj',
      'phone': '9876543212',
    },
    {
      'id': 'V-4',
      'patientId': 'PAT-105',
      'name': 'Dinanath Sharma',
      'age': 78,
      'village': 'Sonapur',
      'time': '11:00 AM',
      'purpose': 'Monthly cognitive health monitoring',
      'status': 'Pending',
      'priority': 'Normal',
      'dateCategory': 'Kal',
      'phone': '9876543215',
    },
    {
      'id': 'V-5',
      'patientId': 'PAT-103',
      'name': 'Haren Roy',
      'age': 69,
      'village': 'Sonapur',
      'time': '03:30 PM',
      'purpose': 'Routine wellness check',
      'status': 'Completed',
      'priority': 'Normal',
      'dateCategory': 'Pichhle',
      'phone': '9876543213',
    },
  ];

  // Alerts Tab State
  String _alertFilter = 'Sabhi';
  final List<Map<String, dynamic>> _alertsList = [
    {
      'id': 'A-1',
      'patientId': 'PAT-101',
      'name': 'Ramesh Das',
      'age': 72,
      'village': 'Rampur Gaon',
      'severity': 'CRITICAL',
      'title': 'Cognitive Score Decline (-24%)',
      'desc': 'Recent gameplay showed sharp drop in picture memory & hand stability. PHC doctor referral recommended.',
      'category': 'Critical',
      'time': '2 hours ago',
      'isResolved': false,
    },
    {
      'id': 'A-2',
      'patientId': 'PAT-104',
      'name': 'Kamla Devi',
      'age': 74,
      'village': 'Rampur Gaon',
      'severity': 'CRITICAL',
      'title': 'Evening Confusion & Disorientation',
      'desc': 'Family reported confusion during sunset hours (Sundowning symptoms). Caregiver counseling required.',
      'category': 'Critical',
      'time': '5 hours ago',
      'isResolved': false,
    },
    {
      'id': 'A-3',
      'patientId': 'PAT-102',
      'name': 'Lakshmi Tai',
      'age': 68,
      'village': 'Dhor Kola',
      'severity': 'MEDIUM',
      'title': 'Missed 3 Daily Brain Games',
      'desc': 'Patient has not performed daily voice and matching exercises for 3 consecutive days.',
      'category': 'Follow-up',
      'time': 'Yesterday',
      'isResolved': false,
    },
    {
      'id': 'A-4',
      'patientId': 'PAT-103',
      'name': 'Haren Roy',
      'age': 69,
      'village': 'Sonapur',
      'severity': 'INFO',
      'title': 'Quarterly Screening Cycle Due',
      'desc': '90-day comprehensive dementia baseline reassessment is due this week.',
      'category': 'Screening Due',
      'time': '2 days ago',
      'isResolved': false,
    },
  ];

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.spa, color: emeraldBrand),
          ),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        actions: [
          if (_currentNavIndex == 1) ...[
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded, color: emeraldBrand, size: 26),
              tooltip: 'Naya Buzurg Jodein',
              onPressed: () => context.push('/asha/onboard'),
            ),
          ] else if (_currentNavIndex == 2) ...[
            IconButton(
              icon: const Icon(Icons.add_task_rounded, color: emeraldBrand, size: 26),
              tooltip: 'Visit Schedule Karein',
              onPressed: () => _showScheduleVisitModal(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 22),
            tooltip: 'Logout ASHA',
            onPressed: () {
              ref.read(ashaAuthProvider.notifier).logout();
              context.go('/asha/login');
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildHomeView(),
            _buildPatientsView(),
            _buildVisitsView(),
            _buildAlertsView(),
            _buildMoreView(),
          ],
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
                _buildNavItem(3, Icons.notifications_active_rounded, 'Alerts', badgeCount: _alertsList.where((a) => a['isResolved'] == false).length),
                _buildNavItem(4, Icons.more_horiz_rounded, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentNavIndex) {
      case 0:
        return 'ASHA Sathi Home';
      case 1:
        return 'Mere Buzurg';
      case 2:
        return 'Ghar Bhraman (Visits)';
      case 3:
        return 'Zaroori Alerts';
      case 4:
        return 'Settings & Tools';
      default:
        return 'Smarana ASHA';
    }
  }

  // ==========================================
  // TAB 0: ASHA HOME VIEW
  // ==========================================
  Widget _buildHomeView() {
    final allPatients = ref.watch(ashaPatientsProvider);
    final stableCount = allPatients.where((p) => p.status == AshaTriageStatus.stable).length;
    final monitorCount = allPatients.where((p) => p.status == AshaTriageStatus.monitor).length;
    final attentionCount = allPatients.where((p) => p.status == AshaTriageStatus.needsAttention).length;

    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // 1. ASHA Welcome Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: emeraldBrand.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: const Center(
                    child: Text('👩‍⚕️', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Namaste Sunita Didi! 🙏',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sonapur PHC • Rampur Sub-centre',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚡ All Sync Systems Online',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Metrics 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Kul Buzurg',
                  value: '${allPatients.length}',
                  subtitle: 'Registered',
                  icon: Icons.group_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => setState(() => _currentNavIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Aaj ki Visits',
                  value: '3 Due',
                  subtitle: 'Home Visits',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => setState(() => _currentNavIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'High Risk Alert',
                  value: '$attentionCount Alert',
                  subtitle: 'Action Needed',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () => setState(() => _currentNavIndex = 3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Screening',
                  value: '28 Purna',
                  subtitle: 'This Month',
                  icon: Icons.fact_check_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/asha/assessment/intro'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // 3. Quick Action Hub
          const Text(
            'Quick Actions (तुरंत कार्य)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Naya Buzurg\nJodein',
                  color: const Color(0xFF059669),
                  onTap: () => context.push('/asha/onboard'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.psychology_rounded,
                  label: 'Screening\nGame Shuru',
                  color: const Color(0xFF6366F1),
                  onTap: () => context.push('/asha/assessment/intro'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.edit_calendar_rounded,
                  label: 'Visit\nSchedule',
                  color: const Color(0xFF0284C7),
                  onTap: () => _showScheduleVisitModal(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.local_hospital_rounded,
                  label: 'Doctor\nReferral',
                  color: const Color(0xFFD97706),
                  onTap: () {
                    if (allPatients.isNotEmpty) {
                      context.push('/asha/action/${allPatients.first.id}', extra: allPatients.first);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // 4. Today's Priority Schedule Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Aaj ke Karyakram (Today’s Schedule)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentNavIndex = 2),
                child: const Text(
                  'Sabhi ➔',
                  style: TextStyle(fontWeight: FontWeight.w800, color: emeraldBrand),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Today's Priority Visit Cards
          ..._visitsList.where((v) => v['dateCategory'] == 'Aaj').map((visit) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: visit['priority'] == 'High' ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF475569)),
                        const SizedBox(height: 2),
                        Text(
                          visit['time'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              visit['name'],
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textDark),
                            ),
                            const SizedBox(width: 6),
                            if (visit['priority'] == 'High')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'HIGH RISK',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          visit['purpose'],
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          visit['village'],
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: emeraldBrand, size: 34),
                    tooltip: 'Start Assessment',
                    onPressed: () => context.push('/asha/assessment/intro'),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // 5. Village Triage Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_rounded, color: emeraldBrand, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Gaon Cognitive Health Overview',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: stableCount == 0 && monitorCount == 0 && attentionCount == 0 ? 1 : (stableCount > 0 ? stableCount : 1),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: monitorCount > 0 ? monitorCount : 1,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: attentionCount > 0 ? attentionCount : 1,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildLegendItem('Stable ($stableCount)', const Color(0xFF10B981)),
                    _buildLegendItem('Monitor ($monitorCount)', const Color(0xFFF59E0B)),
                    _buildLegendItem('Needs Attention ($attentionCount)', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 12),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: PATIENTS VIEW (MERE BUZURG)
  // ==========================================
  Widget _buildPatientsView() {
    final allPatients = ref.watch(ashaPatientsProvider);
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

          const SizedBox(height: 12),

          // Filter Tabs Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill('All (${allPatients.length})', isSelected: _filterStatus == null, onTap: () {
                  setState(() => _filterStatus = null);
                }),
                const SizedBox(width: 8),
                _buildFilterPill(
                  'Stable ($stableCount)',
                  color: const Color(0xFF10B981),
                  isSelected: _filterStatus == AshaTriageStatus.stable,
                  onTap: () => setState(() => _filterStatus = AshaTriageStatus.stable),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  'Monitor ($monitorCount)',
                  color: const Color(0xFFF59E0B),
                  isSelected: _filterStatus == AshaTriageStatus.monitor,
                  onTap: () => setState(() => _filterStatus = AshaTriageStatus.monitor),
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  'Needs Attention ($attentionCount)',
                  color: const Color(0xFFEF4444),
                  isSelected: _filterStatus == AshaTriageStatus.needsAttention,
                  onTap: () => setState(() => _filterStatus = AshaTriageStatus.needsAttention),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Patient List
          Expanded(
            child: filteredPatients.isEmpty
                ? const Center(child: Text('Koi buzzerg nahi mila.'))
                : ListView.separated(
                    itemCount: filteredPatients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = filteredPatients[index];

                      return InkWell(
                        onTap: () => context.push('/asha/action/${p.id}', extra: p),
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
                                  p.name.contains('Lakshmi') || p.name.contains('Kamla') ? '👵' : '👴',
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: p.status.bgColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: p.status.color.withOpacity(0.4)),
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
    );
  }

  // ==========================================
  // TAB 2: VISITS VIEW (GHAR BHRAMAN)
  // ==========================================
  Widget _buildVisitsView() {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    final filteredVisits = _visitsList.where((v) {
      if (_visitFilter == 'Sabhi') return true;
      return v['dateCategory'] == _visitFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips (Aaj, Kal, Pichhle, Sabhi)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill('Aaj (3)', isSelected: _visitFilter == 'Aaj', onTap: () => setState(() => _visitFilter = 'Aaj')),
                const SizedBox(width: 8),
                _buildFilterPill('Kal (1)', isSelected: _visitFilter == 'Kal', onTap: () => setState(() => _visitFilter = 'Kal')),
                const SizedBox(width: 8),
                _buildFilterPill('Pichhle (1)', isSelected: _visitFilter == 'Pichhle', onTap: () => setState(() => _visitFilter = 'Pichhle')),
                const SizedBox(width: 8),
                _buildFilterPill('Sabhi (${_visitsList.length})', isSelected: _visitFilter == 'Sabhi', onTap: () => setState(() => _visitFilter = 'Sabhi')),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Visits List
          Expanded(
            child: filteredVisits.isEmpty
                ? const Center(child: Text('Koi visit scheduled nahi hai.'))
                : ListView.separated(
                    itemCount: filteredVisits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final v = filteredVisits[index];
                      final isHigh = v['priority'] == 'High';
                      final isCompleted = v['status'] == 'Completed';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHigh ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                            width: isHigh ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFF0284C7)),
                                          const SizedBox(width: 4),
                                          Text(
                                            v['time'],
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isHigh)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'PRIORITY VISIT',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                                        ),
                                      ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isCompleted ? '✓ Completed' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isCompleted ? const Color(0xFF059669) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              v['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${v['age']} saal • ${v['village']}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notes_rounded, size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      v['purpose'],
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Action Buttons
                            SizedBox(
                              height: 44,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Calling caregiver for ${v['name']} (${v['phone']})...')),
                                        );
                                      },
                                      icon: const Icon(Icons.call_rounded, size: 18),
                                      label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w800)),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0284C7),
                                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.push('/asha/assessment/intro');
                                      },
                                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                      label: const Text('Start Visit', style: TextStyle(fontWeight: FontWeight.w800)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: emeraldBrand,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: ALERTS VIEW (ZAROORI SUCHNAYEIN)
  // ==========================================
  Widget _buildAlertsView() {
    const textDark = Color(0xFF0F172A);

    final filteredAlerts = _alertsList.where((a) {
      if (_alertFilter == 'Sabhi') return true;
      return a['category'] == _alertFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill('Sabhi (${_alertsList.length})', isSelected: _alertFilter == 'Sabhi', onTap: () => setState(() => _alertFilter = 'Sabhi')),
                const SizedBox(width: 8),
                _buildFilterPill('Critical (2)', color: const Color(0xFFEF4444), isSelected: _alertFilter == 'Critical', onTap: () => setState(() => _alertFilter = 'Critical')),
                const SizedBox(width: 8),
                _buildFilterPill('Follow-up (1)', color: const Color(0xFFF59E0B), isSelected: _alertFilter == 'Follow-up', onTap: () => setState(() => _alertFilter = 'Follow-up')),
                const SizedBox(width: 8),
                _buildFilterPill('Screening Due (1)', color: const Color(0xFF6366F1), isSelected: _alertFilter == 'Screening Due', onTap: () => setState(() => _alertFilter = 'Screening Due')),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Alerts List
          Expanded(
            child: filteredAlerts.isEmpty
                ? const Center(child: Text('Koi alert nahi hai.'))
                : ListView.separated(
                    itemCount: filteredAlerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final a = filteredAlerts[index];
                      final isCritical = a['severity'] == 'CRITICAL';
                      final isResolved = a['isResolved'] == true;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isResolved ? const Color(0xFFF8FAFC) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCritical && !isResolved ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
                            width: isCritical && !isResolved ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
                                      color: isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      a['severity'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  a['time'],
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a['title'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patient: ${a['name']} (${a['age']} yr, ${a['village']})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a['desc'],
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 40,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final allPatients = ref.read(ashaPatientsProvider);
                                        final p = allPatients.firstWhere((item) => item.id == a['patientId'], orElse: () => allPatients.first);
                                        context.push('/asha/action/${p.id}', extra: p);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isCritical ? const Color(0xFFEF4444) : const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Review & Refer ➔', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        a['isResolved'] = !isResolved;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(isResolved ? 'Alert re-opened.' : 'Alert marked as resolved.')),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF64748B),
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(isResolved ? 'Re-open' : 'Dismiss', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: MORE / SETTINGS & TOOLS VIEW
  // ==========================================
  Widget _buildMoreView() {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // ASHA Profile Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFECFDF5),
                child: Text('👩‍⚕️', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sunita Sharma',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'ASHA Worker ID: ASHA-AS-8821',
                      style: TextStyle(fontSize: 12, color: emeraldBrand, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+91 98765 43210 • Sonapur PHC',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Section: Tools & Clinical Guidance
        const Text(
          'Clinical Tools & Guidelines',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark),
        ),
        const SizedBox(height: 10),

        _buildSettingsTile(
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF6366F1),
          title: 'Dementia Care Guidelines (मार्गदर्शिका)',
          subtitle: 'Elderly cognitive assessment protocols',
          onTap: () => _showGuidelinesDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.translate_rounded,
          color: const Color(0xFF0284C7),
          title: 'App ki Bhasha (Language)',
          subtitle: 'Hindi / Assamese / Bengali / English',
          onTap: () => _showLanguageDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.sync_rounded,
          color: const Color(0xFF10B981),
          title: 'Offline Data Sync',
          subtitle: _isSyncing ? 'Syncing...' : 'All 12 records synced with Cloud Server',
          trailing: _isSyncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 22),
          onTap: () async {
            setState(() => _isSyncing = true);
            await Future.delayed(const Duration(milliseconds: 900));
            setState(() => _isSyncing = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Cloud Server Sync Completed Successfully!')),
              );
            }
          },
        ),

        const SizedBox(height: 18),

        // Section: Helpline & Emergency
        const Text(
          'Emergency & Support Helplines',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textDark),
        ),
        const SizedBox(height: 10),

        _buildSettingsTile(
          icon: Icons.local_hospital_rounded,
          color: const Color(0xFFEF4444),
          title: 'PHC Medical Officer (MO)',
          subtitle: '+91 94350 12345 (Dr. Barman)',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connecting to PHC Medical Officer...')),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.phone_in_talk_rounded,
          color: const Color(0xFF8B5CF6),
          title: 'National Dementia Helpline',
          subtitle: 'Toll-free: 14416 (Tele-MANAS)',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling Tele-MANAS Helpline 14416...')),
            );
          },
        ),

        const SizedBox(height: 18),

        // Logout
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            title: const Text(
              'Logout ASHA Account',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
            ),
            subtitle: const Text('Device par patient mode active rahega'),
            onTap: () {
              ref.read(ashaAuthProvider.notifier).logout();
              context.go('/asha/login');
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
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

  Widget _buildNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    const emeraldBrand = Color(0xFF059669);
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? emeraldBrand : const Color(0xFF64748B),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
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

  void _showScheduleVisitModal() {
    final allPatients = ref.read(ashaPatientsProvider);
    String selectedPatient = allPatients.isNotEmpty ? allPatients.first.name : 'Ramesh Das';
    String timeSlot = '11:00 AM';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Naya Home Visit Schedule Karein', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                const Text('Buzurg Chunein:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedPatient,
                  items: allPatients.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
                  onChanged: (val) => setModalState(() => selectedPatient = val ?? selectedPatient),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Samay (Time Slot):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: timeSlot,
                  items: const [
                    DropdownMenuItem(value: '10:00 AM', child: Text('10:00 AM (Subah)')),
                    DropdownMenuItem(value: '11:00 AM', child: Text('11:00 AM (Subah)')),
                    DropdownMenuItem(value: '02:30 PM', child: Text('02:30 PM (Dopahar)')),
                    DropdownMenuItem(value: '04:00 PM', child: Text('04:00 PM (Shaam)')),
                  ],
                  onChanged: (val) => setModalState(() => timeSlot = val ?? timeSlot),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _visitsList.insert(0, {
                          'id': 'V-${DateTime.now().millisecondsSinceEpoch}',
                          'patientId': 'PAT-NEW',
                          'name': selectedPatient,
                          'age': 70,
                          'village': 'Rampur Gaon',
                          'time': timeSlot,
                          'purpose': 'Cognitive re-assessment visit',
                          'status': 'Pending',
                          'priority': 'Normal',
                          'dateCategory': 'Aaj',
                          'phone': '9876543210',
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Visit scheduled for $selectedPatient at $timeSlot!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Schedule Confirm Karein', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Dementia Care Guidelines', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('1. 🔍 Early Symptoms Identification:', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('• Rozmara ke kaamo mein bhoolne ki aadat\n• Raaste ya samay ka andaza na lagna\n• Shaam ko ghabrahat (Sundowning)', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 10),
                Text('2. 🗣️ Communication Best Practices:', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('• Shaant aur dheemi aawaz mein baat karein\n• Ek samay mein ek hi saral prashna poochein\n• Parivar ko sahara aur samay dein', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 10),
                Text('3. 🏥 Referral Criteria to PHC:', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('• Memory score mein 20%+ girawat\n• Haath hilna ya chalne mein asantulan\n• Davai lene mein baar-baar bhool', style: TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Theek Hai (OK)', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669))),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Bhasha Chunein (Select Language)', style: TextStyle(fontWeight: FontWeight.w900)),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bhasha Hindi set ho gayi.')));
              },
              child: const Text('🇮🇳 हिन्दी (Hindi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to Assamese (অসমীয়া).')));
              },
              child: const Text('অসমীয়া (Assamese)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to Bengali (বাংলা).')));
              },
              child: const Text('বাংলা (Bengali)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language set to English.')));
              },
              child: const Text('English (US/India)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

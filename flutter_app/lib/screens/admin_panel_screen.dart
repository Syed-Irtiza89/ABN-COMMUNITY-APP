import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../data/translations.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String _activeTab = 'biz'; // biz, pay, cat, users
  String _bizFilter = 'submissions';
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.currentUser?.role != 'admin') {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13110E) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.shieldAlert, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '\${t(lang, 'adminPanel')} Restricted',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang == 'en'
                        ? 'Administrative controls, business vetting approvals, and category creations are restricted to platform administrators only.'
                        : 'إن صلاحيات الموافقة وتعديل التصنيفات وتوقيف العضويات محصورة فقط بمسؤولي إدارة التطبيق لحماية المجتمع.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sliders, color: Color(0xFFFFA048)),
                      const SizedBox(width: 8),
                      Text(t(lang, 'adminTitle'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Platform-wide control, dues audit, and directory indexing',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  // Segment Bar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13110E) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('biz', 'Vetting', LucideIcons.award),
                        _buildTabButton('pay', 'Dues', LucideIcons.dollarSign),
                        _buildTabButton('cat', 'Categories', LucideIcons.grid),
                        _buildTabButton('users', 'Users', LucideIcons.users),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _activeTab == 'biz' ? _buildBizVetting(provider, isDark) : Center(child: Text('Coming Soon')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA048) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBizVetting(DirectoryProvider provider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1914) : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PLATFORM REVENUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('\$\${provider.payments.length * 50}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1914) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTIVE SUBS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("\${provider.businesses.where((b) => b.status == 'active').length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Add List of Businesses Here...
        Center(child: Text('Business Vetting List', style: TextStyle(color: Colors.grey))),
      ],
    );
  }
}

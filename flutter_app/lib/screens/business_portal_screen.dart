import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../data/translations.dart';

class BusinessPortalScreen extends StatefulWidget {
  final VoidCallback onOpenAuth;

  const BusinessPortalScreen({super.key, required this.onOpenAuth});

  @override
  State<BusinessPortalScreen> createState() => _BusinessPortalScreenState();
}

class _BusinessPortalScreenState extends State<BusinessPortalScreen> {
  String _activeTab = 'dash'; // dash, edit, pay
  String? _registrationType; // business, service

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (provider.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF191613) : Colors.orange.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.orange.shade200),
                  ),
                  child: const Icon(LucideIcons.briefcase, size: 32, color: Color(0xFFFFA048)),
                ),
                const SizedBox(height: 16),
                Text(
                  t(lang, 'businessPortal'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  lang == 'en'
                      ? 'Sign in with your Business Member account to list your shop, update service operations, or manage your \$50/month membership fee.'
                      : 'سجل الدخول بحساب شريك الدليل لتسجيل عملك وإدارته وتفعيل اشتراكك الشهري بقيمة 50\$/شهرياً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onOpenAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA048),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    t(lang, 'signIn'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final myBusiness = provider.businesses.cast().firstWhere(
      (b) => b.ownerId == provider.currentUser!.id,
      orElse: () => null,
    );

    if (myBusiness == null) {
      if (_registrationType == null) {
        return _buildRegistrationSelection(lang, isDark);
      } else {
        return _buildRegistrationForm(lang, isDark);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\${t(lang, 'businessPortal')} Dashboard",
                style: const TextStyle(fontSize: 10, color: Color(0xFFFFA048), fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    myBusiness.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  if (myBusiness.isVerified) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.shieldCheck, size: 10, color: Colors.green),
                          SizedBox(width: 4),
                          Text('VERIFIED', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: myBusiness.status == 'suspended' ? null : () {
                        setState(() => _activeTab = 'edit');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF191613) : Colors.grey.shade200,
                        foregroundColor: isDark ? Colors.grey.shade300 : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(LucideIcons.edit, size: 14),
                      label: Text(lang == 'en' ? 'Edit Details' : 'تعديل البيانات', style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _activeTab = 'pay');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA048),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(LucideIcons.creditCard, size: 14),
                      label: Text(lang == 'en' ? 'Pay Membership' : 'دفع الاشتراك', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_activeTab == 'dash') _buildDashboardView(lang, isDark, myBusiness),
              if (_activeTab == 'edit') _buildEditForm(lang, isDark),
              if (_activeTab == 'pay') _buildPaymentGateway(lang, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationSelection(String lang, bool isDark) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'en' ? 'Choose Registration Type' : 'اختر نوع التسجيل',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                lang == 'en' ? 'Select how you want to join the community directory.' : 'اختر كيف تريد الانضمام إلى دليل المجتمع.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              
              _RegCard(
                icon: LucideIcons.briefcase,
                title: lang == 'en' ? 'Register as a Business' : 'سجل كصاحب عمل',
                price: '\$50 / month',
                desc: lang == 'en' ? 'Best for shops, restaurants, and physical store locations.' : 'الأفضل للمتاجر والمطاعم والمواقع التجارية الفعلية.',
                color: const Color(0xFFFFA048),
                isDark: isDark,
                onTap: () => setState(() => _registrationType = 'business'),
              ),
              const SizedBox(height: 16),
              _RegCard(
                icon: LucideIcons.userCheck,
                title: lang == 'en' ? 'Register as a Service Provider' : 'سجل كمقدم خدمة',
                price: '\$30 / month',
                desc: lang == 'en' ? 'Best for independent professionals, plumbers, and freelancers.' : 'الأفضل للمهنيين المستقلين والحرفيين.',
                color: Colors.blue,
                isDark: isDark,
                onTap: () => setState(() => _registrationType = 'service'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(String lang, bool isDark) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => setState(() => _registrationType = null),
        ),
        title: Text(lang == 'en' ? 'Register' : 'تسجيل', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Text(lang == 'en' ? 'Registration form goes here...' : 'نموذج التسجيل...'),
      ),
    );
  }

  Widget _buildDashboardView(String lang, bool isDark, dynamic myBusiness) {
    final isActive = myBusiness.status == 'active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
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
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t(lang, 'membershipStatus'),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? t(lang, 'active') : t(lang, 'suspended'),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isActive ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isActive)
            Text(
              lang == 'en'
                  ? 'Your page is actively appearing in directory search listings. Expires: \${myBusiness.membershipExpiryDate}'
                  : 'صفحتك نشطة وتظهر للجميع. ينتهي: \${myBusiness.membershipExpiryDate}',
              style: const TextStyle(fontSize: 12),
            )
          else
            Text(
              lang == 'en'
                  ? 'Your listing has disappeared from customer search until the monthly update of \$50/month is settled.'
                  : 'تم إخفاء عملك مؤقتاً وسيتم تفعيله فور إتمام السداد.',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildEditForm(String lang, bool isDark) {
    return Center(child: Text('Edit Form'));
  }

  Widget _buildPaymentGateway(String lang, bool isDark) {
    return Center(child: Text('Payment Gateway'));
  }
}

class _RegCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final String desc;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _RegCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.desc,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13110E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade200),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Text(price, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(LucideIcons.arrowRight, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text(desc, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ),
          ],
        ),
      ),
    );
  }
}

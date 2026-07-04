import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../models/models.dart';
import '../data/translations.dart';

void showBusinessDetails(BuildContext context, Business business) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BusinessDetailsModal(business: business),
  );
}

class BusinessDetailsModal extends StatefulWidget {
  final Business business;

  const BusinessDetailsModal({super.key, required this.business});

  @override
  State<BusinessDetailsModal> createState() => _BusinessDetailsModalState();
}

class _BusinessDetailsModalState extends State<BusinessDetailsModal> {
  int _rating = 5;
  String _comment = '';
  String _reviewError = '';
  String _reviewSuccess = '';

  int _whatsappClicks = 34;
  int _callClicks = 19;

  bool _isBusinessOpenNow(String workingHours) {
    if (workingHours.contains('24/7')) return true;
    return true; // Simplified for now
  }

  void _submitReview() {
    final provider = context.read<DirectoryProvider>();
    final lang = provider.language;
    
    if (provider.currentUser == null) {
      setState(() => _reviewError = lang == 'en' ? 'You must be signed in to submit a review!' : 'يجب تسجيل الدخول لإضافة تقييم!');
      return;
    }
    if (_comment.trim().isEmpty) {
      setState(() => _reviewError = lang == 'en' ? 'Please share details in your comment.' : 'يرجى كتابة تعليقك أولاً.');
      return;
    }

    final newReview = Review(
      id: 'rev-\${DateTime.now().millisecondsSinceEpoch}',
      businessId: widget.business.id,
      userName: provider.currentUser!.name,
      rating: _rating.toDouble(),
      comment: _comment,
      date: DateTime.now().toIso8601String().split('T')[0],
    );

    provider.addReview(newReview);
    setState(() {
      _comment = '';
      _reviewError = '';
      _reviewSuccess = lang == 'en' ? 'Review posted! Jazakumullah Khayran.' : 'تم نشر المراجعة! جزاكم الله خيراً.';
    });
    
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _reviewSuccess = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final biz = widget.business;

    final isOpen = _isBusinessOpenNow(biz.workingHours.en);
    final isFav = provider.favorites.contains(biz.id);
    final businessReviews = provider.reviews.where((r) => r.businessId == biz.id).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0E0C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Cover Image
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        biz.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.network(
                          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=600&h=400',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => provider.toggleFavorite(biz.id),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isFav ? const Color(0xFFFFA048) : Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.heart, size: 20, color: isFav ? Colors.black : Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.x, size: 20, color: Color(0xFFFFA048)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Header Info
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF0F0E0C) : Colors.white, width: 4),
                            image: DecorationImage(
                              image: NetworkImage(biz.logoUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF201B15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      lang == 'ar' ? biz.subcategory.ar : biz.subcategory.en,
                                      style: const TextStyle(fontSize: 10, color: Color(0xFFFFA048), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (biz.isVerified) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.checkCircle, size: 10, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            t(lang, 'verified'),
                                            style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                biz.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13110E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'en' ? 'About Our Business' : 'نبذة وتفاصيل العمل',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang == 'ar' ? biz.description.ar : biz.description.en,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFF2D2319)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(LucideIcons.clock, size: 16, color: Color(0xFFFFA048)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("\${t(lang, 'workingHours')}:", style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isOpen ? (lang == 'ar' ? '🟢 مفتوح الآن' : '🟢 Open Now') : (lang == 'ar' ? '🔴 مغلق الآن' : '🔴 Closed Now'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isOpen ? Colors.green : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(lang == 'ar' ? biz.workingHours.ar : biz.workingHours.en),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Actions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13110E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t(lang, 'contactBusiness'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                            ),
                            const SizedBox(height: 12),
                            _ActionButton(
                              icon: LucideIcons.phone,
                              label: t(lang, 'callNow'),
                              color: const Color(0xFFFFA048),
                              onTap: () {
                                setState(() => _callClicks++);
                              },
                            ),
                            const SizedBox(height: 8),
                            _ActionButton(
                              icon: LucideIcons.messageSquare,
                              label: t(lang, 'openWhatsapp'),
                              color: Colors.green,
                              bg: Colors.green.withOpacity(0.1),
                              onTap: () {
                                setState(() => _whatsappClicks++);
                              },
                            ),
                            const SizedBox(height: 8),
                            _ActionButton(
                              icon: LucideIcons.mapPin,
                              label: t(lang, 'openMap'),
                              color: Colors.blue,
                              bg: Colors.blue.withOpacity(0.1),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reviews
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13110E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t(lang, 'reviews'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                                ),
                                Text(
                                  "${businessReviews.length} ${lang == 'en' ? 'responses' : 'مشاركات'}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (businessReviews.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    lang == 'en' ? 'No community feedback yet. Be the first to review!' : 'لا توجد تقييمات من المجتمع حالياً. كن أول من يكتب تجربته!',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: businessReviews.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final rev = businessReviews[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F0E0C) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Row(
                                              children: List.generate(5, (i) => Icon(
                                                LucideIcons.star,
                                                size: 12,
                                                color: i < rev.rating ? const Color(0xFFFFA048) : Colors.grey,
                                              )),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(rev.comment, style: const TextStyle(fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(rev.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFF2D2319)),
                            const SizedBox(height: 16),
                            
                            // Write Review
                            Text(
                              t(lang, 'writeReview'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                            ),
                            if (_reviewError.isNotEmpty)
                              Padding(padding: const EdgeInsets.only(top: 8), child: Text(_reviewError, style: const TextStyle(color: Colors.red, fontSize: 12))),
                            if (_reviewSuccess.isNotEmpty)
                              Padding(padding: const EdgeInsets.only(top: 8), child: Text(_reviewSuccess, style: const TextStyle(color: Colors.green, fontSize: 12))),
                            
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text("\${t(lang, 'ratingLabel')}:", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(5, (index) => GestureDetector(
                                    onTap: () => setState(() => _rating = index + 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(
                                        LucideIcons.star,
                                        size: 20,
                                        color: index < _rating ? const Color(0xFFFFA048) : Colors.grey,
                                      ),
                                    ),
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F0E0C) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade300),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    maxLines: 2,
                                    onChanged: (val) => _comment = val,
                                    decoration: InputDecoration(
                                      hintText: t(lang, 'commentPlaceholder'),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _submitReview,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFA048),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(LucideIcons.send, size: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? bg;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg ?? (isDark ? const Color(0xFF2E2822) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF3D3328) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

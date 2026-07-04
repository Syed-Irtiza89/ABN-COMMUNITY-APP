import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../data/translations.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final savedBusinesses = provider.businesses
        .where((b) => provider.favorites.contains(b.id))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t(lang, 'savedLists'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(\${savedBusinesses.length})',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFFA048)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'en' ? 'Quickly access your bookmarked community listings' : 'الوصول السريع إلى الأنشطة المحفوظة والموثقة',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2D2319)),
            
            Expanded(
              child: savedBusinesses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.heart, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            t(lang, 'noSaved'),
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA048),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              // Action handled at parent navigation level in full app
                            },
                            icon: const Icon(LucideIcons.bookOpen, size: 16),
                            label: Text(
                              lang == 'en' ? 'Browse Directory' : 'تصفح الدليل الآن',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: savedBusinesses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final biz = savedBusinesses[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF13110E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF201B15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF2D2319)),
                                      ),
                                      child: Text(
                                        lang == 'ar' ? biz.subcategory.ar : biz.subcategory.en,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFFA048),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      biz.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.mapPin, size: 12, color: Color(0xFFFFA048)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '\${t(lang, biz.city.toLowerCase())} (\${biz.area})',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () => provider.toggleFavorite(biz.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(LucideIcons.heart, size: 20, color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.star, size: 12, color: Color(0xFFFFA048)),
                                      const SizedBox(width: 2),
                                      Text(
                                        biz.rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFA048),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../data/translations.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _inputSearch = '';
  String _selectedCity = 'all';

  bool _isBusinessOpenNow(String workingHours) {
    // Basic implementation for demonstration
    if (workingHours.contains('24/7')) return true;
    return true; // Simplified for now
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'Shirt': return LucideIcons.shirt;
      case 'ShoppingBag': return LucideIcons.shoppingBag;
      case 'BookOpen': return LucideIcons.bookOpen;
      case 'Tv': return LucideIcons.tv;
      case 'Gem': return LucideIcons.gem;
      case 'Book': return LucideIcons.book;
      case 'Wrench': return LucideIcons.wrench;
      case 'Zap': return LucideIcons.zap;
      case 'Hammer': return LucideIcons.hammer;
      case 'UserCheck': return LucideIcons.userCheck;
      case 'Scale': return LucideIcons.scale;
      case 'HardHat': return LucideIcons.hardHat;
      case 'Utensils': return LucideIcons.utensils;
      case 'Croissant': return LucideIcons.croissant;
      case 'Soup': return LucideIcons.soup;
      case 'Settings': return LucideIcons.settings;
      case 'Calculator': return LucideIcons.calculator;
      case 'Building': return LucideIcons.building;
      case 'Sparkles': return LucideIcons.sparkles;
      default: return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final CITY_KEYS = [
      {'key': 'all', 'label': t(lang, 'allCities')},
      {'key': 'New York', 'label': t(lang, 'newyork')},
      {'key': 'Los Angeles', 'label': t(lang, 'losangeles')},
      {'key': 'Chicago', 'label': t(lang, 'chicago')},
      {'key': 'Houston', 'label': t(lang, 'houston')},
      {'key': 'Miami', 'label': t(lang, 'miami')},
    ];

    final activeBusinesses = provider.businesses
        .where((b) => b.status == BusinessStatus.active && (_selectedCity == 'all' || b.city == _selectedCity))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Top Nav & Search
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFA048),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F0E0C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF2E2419) : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(LucideIcons.search, size: 20, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => _inputSearch = val,
                          decoration: InputDecoration(
                            hintText: t(lang, 'searchPlaceholder'),
                            border: InputBorder.none,
                            hintStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF201B15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3A2F22)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 12, color: Color(0xFFFFA048)),
                            const SizedBox(width: 4),
                            Text(
                              t(lang, 'newyork'),
                              style: const TextStyle(fontSize: 10, color: Color(0xFFFFA048), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // City Filter
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CITY_KEYS.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final city = CITY_KEYS[index];
                  final isSelected = _selectedCity == city['key'];
                  final count = city['key'] == 'all'
                      ? provider.businesses.where((b) => b.status == BusinessStatus.active).length
                      : provider.businesses.where((b) => b.status == BusinessStatus.active && b.city == city['key']).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCity = city['key']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFA048) : (isDark ? const Color(0xFF13110E) : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFFFFA048) : (isDark ? const Color(0xFF2D2319) : Colors.transparent)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.mapPin, size: 14, color: isSelected ? Colors.black : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            city['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : (isDark ? Colors.grey.shade400 : Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black.withOpacity(0.2) : const Color(0xFF201B15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '\$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : const Color(0xFFFFA048),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t(lang, 'categories').toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    Text(
                      t(lang, 'seeAll'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFFA048), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.arrowRight, size: 12, color: Color(0xFFFFA048)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = provider.categories[index];
                  return Container(
                    width: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isDark 
                          ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF191512), Color(0xFF0F0E0C)])
                          : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.grey.shade50]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF201B15) : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF3A2E22) : Colors.orange.shade100),
                          ),
                          child: Icon(_getIcon(cat.iconName), color: const Color(0xFFFFA048), size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang == 'ar' ? cat.name.ar : cat.name.en,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Register Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFA048), Color(0xFFD87D2E)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'en' ? 'Register as a Business' : 'سجل كصاحب عمل',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      Text(
                        lang == 'en' ? 'Join the community directory today' : 'انضم لدليل المجتمع اليوم',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Icon(LucideIcons.arrowRight, color: Colors.black, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // All Businesses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t(lang, 'allBusinesses').toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                Text(
                  t(lang, 'seeAll'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFFA048), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeBusinesses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final biz = activeBusinesses[index];
                final isOpen = _isBusinessOpenNow(biz.workingHours.en);
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
                            Text(
                              biz.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              lang == 'ar' ? biz.subcategory.ar : biz.subcategory.en,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: Color(0xFFFFA048)),
                                const SizedBox(width: 4),
                                Text(
                                  '\${biz.city} (\${biz.area})',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (biz.isVerified)
                            const Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
                          const SizedBox(height: 4),
                          Text(
                            '★ \${biz.rating}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOpen ? (lang == 'ar' ? 'مفتوح' : 'Open') : (lang == 'ar' ? 'مغلق' : 'Closed'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isOpen ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

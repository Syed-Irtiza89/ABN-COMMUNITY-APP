import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../providers/directory_provider.dart';
import '../data/translations.dart';
import '../models/models.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCity = 'All';
  String _selectedCategory = 'All';
  Timer? _debounce;
  bool _isSearching = false;

  final List<String> _cities = ['All', 'Baghdad', 'Najaf', 'Karbala', 'Basra', 'Erbil'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = true);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _isSearching = false;
      });
    });
  }

  bool _isBusinessOpenNow(String workingHours) {
    if (workingHours.contains('24/7')) return true;
    return true; // Simplified for now
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCity = 'All';
      _selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredBusinesses = provider.businesses.where((biz) {
      if (biz.status != BusinessStatus.active) return false;

      final q = _searchQuery.toLowerCase().trim();
      final matchQuery = q.isEmpty ||
          biz.name.toLowerCase().contains(q) ||
          biz.subcategory.en.toLowerCase().contains(q) ||
          biz.subcategory.ar.toLowerCase().contains(q) ||
          biz.area.toLowerCase().contains(q);

      final matchCity = _selectedCity == 'All' || biz.city == _selectedCity;
      final matchCategory = _selectedCategory == 'All' || biz.categoryId == _selectedCategory;

      return matchQuery && matchCity && matchCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang == 'en' ? 'Find a business' : 'ابحث عن نشاط تجاري',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13110E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF2D2319) : Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: lang == 'en' ? 'Plumber, restaurant, bookstore...' : 'سباك، مطعم، مكتبة كتب...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20, color: Colors.grey),
                        suffixIcon: _isSearching 
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFA048)),
                              ),
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cities
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        final isSelected = _selectedCity == city;
                        final label = city == 'All' ? t(lang, 'allCities') : t(lang, city.toLowerCase());

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCity = city),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFFA048) : (isDark ? const Color(0xFF191613).withOpacity(0.55) : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFA048) : (isDark ? const Color(0xFF2D2319) : Colors.transparent),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 12, color: isSelected ? Colors.black : Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categories
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: lang == 'en' ? 'All' : 'الكل',
                          isSelected: _selectedCategory == 'All',
                          onTap: () => setState(() => _selectedCategory = 'All'),
                        ),
                        const SizedBox(width: 8),
                        ...provider.categories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _CategoryChip(
                              label: lang == 'ar' ? cat.name.ar : cat.name.en,
                              isSelected: _selectedCategory == cat.id,
                              onTap: () => setState(() => _selectedCategory = cat.id),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Result Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\${_isSearching ? '...' : filteredBusinesses.length} \${t(lang, 'resultsCount')}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCity != 'All' || _selectedCategory != 'All')
                        GestureDetector(
                          onTap: _clearFilters,
                          child: Text(
                            lang == 'en' ? 'Reset Filters' : 'إعادة ضبط التصفية',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA048)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFA048)))
                : filteredBusinesses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(t(lang, 'noResults'), style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredBusinesses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final biz = filteredBusinesses[index];
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                          '\${t(lang, biz.city.toLowerCase())} | \${biz.area}',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF191613).withOpacity(0.3) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFA048) : (isDark ? const Color(0xFF2D2319).withOpacity(0.5) : Colors.transparent),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFFFFA048) : Colors.grey,
          ),
        ),
      ),
    );
  }
}

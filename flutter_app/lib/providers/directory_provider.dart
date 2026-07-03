import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class DirectoryProvider with ChangeNotifier {
  UserProfile? _currentUser;
  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.system;
  
  List<Category> _categories = initialCategories;
  List<Business> _businesses = initialBusinesses;
  List<Review> _reviews = initialReviews;
  List<PaymentRecord> _payments = initialPayments;
  List<Product> _products = initialProducts;
  List<Order> _orders = initialOrders;
  List<String> _favorites = [];
  
  List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      title: 'App Launched!',
      message: 'Welcome to the Shia Community Business Directory application.',
      date: '2026-06-19',
      isRead: false,
      receiverRole: 'all',
    ),
  ];

  // Getters
  UserProfile? get currentUser => _currentUser;
  String get language => _language;
  ThemeMode get themeMode => _themeMode;
  List<Category> get categories => _categories;
  List<Business> get businesses => _businesses;
  List<Review> get reviews => _reviews;
  List<PaymentRecord> get payments => _payments;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<String> get favorites => _favorites;
  List<AppNotification> get notifications => _notifications;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories = [..._categories, category];
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories = _categories.where((c) => c.id != id).toList();
    notifyListeners();
  }

  void addBusiness(Business business) {
    _businesses = [..._businesses, business];
    addNotification('New Business Listed', '${business.name} has registered.', 'admin');
    notifyListeners();
  }

  void updateBusiness(Business updated) {
    _businesses = _businesses.map((b) => b.id == updated.id ? updated : b).toList();
    notifyListeners();
  }

  void removeBusiness(String id) {
    _businesses = _businesses.where((b) => b.id != id).toList();
    notifyListeners();
  }

  void addReview(Review review) {
    _reviews = [review, ..._reviews];
    
    // Recalculate rating
    _businesses = _businesses.map((biz) {
      if (biz.id == review.businessId) {
        final bizReviews = _reviews.where((r) => r.businessId == review.businessId).toList();
        final totalRating = bizReviews.fold(0.0, (sum, r) => sum + r.rating);
        final newAvg = totalRating / bizReviews.length;
        return Business(
          id: biz.id, ownerId: biz.ownerId, name: biz.name, logoUrl: biz.logoUrl,
          coverUrl: biz.coverUrl, description: biz.description, categoryId: biz.categoryId,
          subcategory: biz.subcategory, address: biz.address, city: biz.city, area: biz.area,
          isVerified: biz.isVerified, status: biz.status, phone: biz.phone, whatsapp: biz.whatsapp,
          website: biz.website, workingHours: biz.workingHours, membershipExpiryDate: biz.membershipExpiryDate,
          gallery: biz.gallery, rating: newAvg, reviewsCount: bizReviews.length,
        );
      }
      return biz;
    }).toList();
    
    notifyListeners();
  }

  void toggleFavorite(String businessId) {
    if (_favorites.contains(businessId)) {
      _favorites = _favorites.where((id) => id != businessId).toList();
    } else {
      _favorites = [..._favorites, businessId];
    }
    notifyListeners();
  }

  void addPayment(PaymentRecord payment) {
    _payments = [payment, ..._payments];
    
    _businesses = _businesses.map((biz) {
      if (biz.id == payment.businessId) {
        final now = DateTime.now();
        final expiry = now.add(const Duration(days: 30));
        final expiryString = "\${expiry.year}-\${expiry.month.toString().padLeft(2, '0')}-\${expiry.day.toString().padLeft(2, '0')}";
        return Business(
          id: biz.id, ownerId: biz.ownerId, name: biz.name, logoUrl: biz.logoUrl,
          coverUrl: biz.coverUrl, description: biz.description, categoryId: biz.categoryId,
          subcategory: biz.subcategory, address: biz.address, city: biz.city, area: biz.area,
          isVerified: biz.isVerified, status: BusinessStatus.active, phone: biz.phone, whatsapp: biz.whatsapp,
          website: biz.website, workingHours: biz.workingHours, membershipExpiryDate: expiryString,
          gallery: biz.gallery, rating: biz.rating, reviewsCount: biz.reviewsCount,
        );
      }
      return biz;
    }).toList();
    
    final biz = _businesses.firstWhere((b) => b.id == payment.businessId);
    addNotification(
      'Subscription Renewed',
      'Membership for \${biz.name} has been renewed successfully for \$50/month.',
      'business',
    );
    notifyListeners();
  }

  void addProduct(Product product) {
    _products = [product, ..._products];
    notifyListeners();
  }

  void updateOrderStatus(String id, String status) {
    _orders = _orders.map((o) {
      if (o.id == id) {
        return Order(
          id: o.id, businessId: o.businessId, customerName: o.customerName,
          customerPhone: o.customerPhone, items: o.items, totalAmount: o.totalAmount,
          status: status, date: o.date,
        );
      }
      return o;
    }).toList();
    notifyListeners();
  }

  void addNotification(String title, String message, String receiverRole) {
    final newNotif = AppNotification(
      id: 'notif-\${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      date: DateTime.now().toIso8601String().split('T')[0],
      isRead: false,
      receiverRole: receiverRole,
    );
    _notifications = [newNotif, ..._notifications];
    notifyListeners();
  }

  void markNotificationsAsRead() {
    _notifications = _notifications.map((n) => AppNotification(
      id: n.id, title: n.title, message: n.message, date: n.date,
      isRead: true, receiverRole: n.receiverRole,
    )).toList();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }

  void signIn(String email, String phone, UserRole role, [String? name]) {
    final fallbackName = name ?? (email.split('@')[0].isEmpty ? 'User' : email.split('@')[0]);
    final stableId = '\${role.toString().split('.').last}-\${email.replaceAll(RegExp(r'[^a-z0-9]', caseSensitive: false), '').toLowerCase()}';
    
    _currentUser = UserProfile(
      id: stableId,
      email: email,
      phone: phone,
      name: fallbackName,
      role: role,
      preferredLanguage: _language,
    );
    addNotification('Login Successful', 'Assalamu Alaykum, \$fallbackName. Welcome back!', role.toString().split('.').last);
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}

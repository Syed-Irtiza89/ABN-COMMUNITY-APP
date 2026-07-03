class LocalizedString {
  final String en;
  final String ar;

  LocalizedString({required this.en, required this.ar});

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      en: json['en'] as String,
      ar: json['ar'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};
}

enum UserRole { customer, business, admin }

class UserProfile {
  final String id;
  final String email;
  final String phone;
  final String name;
  final UserRole role;
  final String preferredLanguage;

  UserProfile({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    required this.preferredLanguage,
  });
}

class Category {
  final String id;
  final LocalizedString name;
  final String group;
  final String iconName;

  Category({
    required this.id,
    required this.name,
    required this.group,
    required this.iconName,
  });
}

enum BusinessStatus { active, suspended, pending }

class Business {
  final String id;
  final String ownerId;
  final String name;
  final String logoUrl;
  final String coverUrl;
  final LocalizedString description;
  final String categoryId;
  final LocalizedString subcategory;
  final String address;
  final String city;
  final String area;
  final bool isVerified;
  final BusinessStatus status;
  final String phone;
  final String whatsapp;
  final String? website;
  final LocalizedString workingHours;
  final String membershipExpiryDate;
  final List<String> gallery;
  final double rating;
  final int reviewsCount;

  Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.logoUrl,
    required this.coverUrl,
    required this.description,
    required this.categoryId,
    required this.subcategory,
    required this.address,
    required this.city,
    required this.area,
    required this.isVerified,
    required this.status,
    required this.phone,
    required this.whatsapp,
    this.website,
    required this.workingHours,
    required this.membershipExpiryDate,
    required this.gallery,
    required this.rating,
    required this.reviewsCount,
  });
}

class Review {
  final String id;
  final String businessId;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class PaymentRecord {
  final String id;
  final String businessId;
  final double amount;
  final String date;
  final String status;
  final String refNo;

  PaymentRecord({
    required this.id,
    required this.businessId,
    required this.amount,
    required this.date,
    required this.status,
    required this.refNo,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String date;
  final bool isRead;
  final String receiverRole;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.receiverRole,
  });
}

class Product {
  final String id;
  final String businessId;
  final LocalizedString name;
  final LocalizedString description;
  final double price;
  final String imageUrl;
  final bool inStock;

  Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
  });
}

class OrderItem {
  final String productId;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
  });
}

class Order {
  final String id;
  final String businessId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String date;

  Order({
    required this.id,
    required this.businessId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
  });
}

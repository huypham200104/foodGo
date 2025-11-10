import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String? name;
  final String? phone;
  final String? street;      // Số nhà, tên đường
  final String? ward;        // Phường/Xã
  final String? district;    // Quận/Huyện
  final String? city;        // Thành phố/Tỉnh
  final String? detail;      // Địa chỉ chi tiết đầy đủ
  final String? note;        // Ghi chú
  final String? label;       // Nhãn địa chỉ (Nhà, Văn phòng, etc.)
  final bool isDefault;
  final String? userId;
  final double? latitude;    // Tọa độ GPS (tùy chọn)
  final double? longitude;   // Tọa độ GPS (tùy chọn)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    this.name,
    this.phone,
    this.street,
    this.ward,
    this.district,
    this.city,
    this.detail,
    this.note,
    this.label,
    this.isDefault = false,
    this.userId,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // Safe getters - trả về string rỗng thay vì null
  String get safeName => name?.isNotEmpty == true ? name! : 'Địa chỉ';
  String get safePhone => phone?.isNotEmpty == true ? phone! : '';
  String get safeStreet => street?.isNotEmpty == true ? street! : '';
  String get safeWard => ward?.isNotEmpty == true ? ward! : '';
  String get safeDistrict => district?.isNotEmpty == true ? district! : '';
  String get safeCity => city?.isNotEmpty == true ? city! : '';
  String get safeDetail => detail?.isNotEmpty == true ? detail! : '';
  String get safeNote => note?.isNotEmpty == true ? note! : '';
  String get safeLabel => label?.isNotEmpty == true ? label! : name?.isNotEmpty == true ? name! : 'Địa chỉ';
  
  // Getter for full address - build từ các thành phần hoặc dùng detail
  String get fullAddress {
    if (detail?.isNotEmpty == true) {
      return detail!;
    }
    
    // Build từ các thành phần
    final parts = <String>[];
    if (street?.isNotEmpty == true) parts.add(street!);
    if (ward?.isNotEmpty == true) parts.add(ward!);
    if (district?.isNotEmpty == true) parts.add(district!);
    if (city?.isNotEmpty == true) parts.add(city!);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Chưa có địa chỉ';
  }

  // Getter for short address (chỉ district và city)
  String get shortAddress {
    final parts = <String>[];
    if (district?.isNotEmpty == true) parts.add(district!);
    if (city?.isNotEmpty == true) parts.add(city!);
    return parts.isNotEmpty ? parts.join(', ') : 'Chưa có địa chỉ';
  }

  // Check if address has GPS coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Check if address is complete
  bool get isComplete {
    return (name?.isNotEmpty == true || label?.isNotEmpty == true) &&
           phone?.isNotEmpty == true &&
           (detail?.isNotEmpty == true || 
            (street?.isNotEmpty == true && 
             ward?.isNotEmpty == true && 
             district?.isNotEmpty == true && 
             city?.isNotEmpty == true));
  }

  // Create AddressModel from Firestore document
  factory AddressModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AddressModel(
      id: id,
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      street: data['street'] as String?,
      ward: data['ward'] as String?,
      district: data['district'] as String?,
      city: data['city'] as String?,
      detail: data['detail'] as String?,
      note: data['note'] as String?,
      label: data['label'] as String?,
      isDefault: data['isDefault'] as bool? ?? false,
      userId: data['userId'] as String?,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert AddressModel to Firestore document
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'name': name,
      'phone': phone,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'detail': detail,
      'note': note,
      'label': label,
      'isDefault': isDefault,
      'userId': userId,
    };

    // Include GPS coordinates if available
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    // Only include timestamps if they exist
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return data;
  }

  // Create copy with updated fields
  AddressModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? street,
    String? ward,
    String? district,
    String? city,
    String? detail,
    String? note,
    String? label,
    bool? isDefault,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      detail: detail ?? this.detail,
      note: note ?? this.note,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'detail': detail,
      'note': note,
      'label': label,
      'isDefault': isDefault,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'],
      phone: json['phone'],
      street: json['street'],
      ward: json['ward'],
      district: json['district'],
      city: json['city'],
      detail: json['detail'],
      note: json['note'],
      label: json['label'],
      isDefault: json['isDefault'] ?? false,
      userId: json['userId'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Validate address data
  bool get isValid {
    return (name?.isNotEmpty == true || label?.isNotEmpty == true) &&
           phone?.isNotEmpty == true &&
           userId?.isNotEmpty == true &&
           (detail?.isNotEmpty == true || fullAddress.isNotEmpty);
  }

  // Format for display in UI
  String get displayAddress {
    if (detail?.isNotEmpty == true) {
      return detail!;
    }
    return fullAddress;
  }

  // Format for delivery
  String get deliveryDisplay {
    final addressText = displayAddress;
    final phoneText = phone?.isNotEmpty == true ? ' - ${phone!}' : '';
    return '$addressText$phoneText';
  }

  // Get display name cho UI
  String get displayName {
    return safeLabel.isNotEmpty ? safeLabel : safeName;
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, name: $name, label: $label, fullAddress: $fullAddress, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.street == street &&
        other.ward == ward &&
        other.district == district &&
        other.city == city &&
        other.detail == detail &&
        other.note == note &&
        other.label == label &&
        other.isDefault == isDefault &&
        other.userId == userId &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      phone,
      street,
      ward,
      district,
      city,
      detail,
      note,
      label,
      isDefault,
      userId,
      latitude,
      longitude,
    );
  }

  // Helper methods for address manipulation
  static List<String> parseAddress(String fullAddress) {
    // Simple parsing logic - có thể cải thiện với regex hoặc API
    final parts = fullAddress.split(',').map((e) => e.trim()).toList();
    return parts;
  }

  static AddressModel createFromFullAddress({
    required String name,
    required String phone,
    required String fullAddress,
    String? userId,
    String? label,
    bool isDefault = false,
  }) {
    return AddressModel(
      id: '',
      name: name,
      phone: phone,
      detail: fullAddress,
      label: label,
      isDefault: isDefault,
      userId: userId,
    );
  }

  // Create empty address for forms
  static AddressModel empty({String? userId}) {
    return AddressModel(
      id: '',
      userId: userId,
    );
  }

  // Distance calculation (if GPS coordinates available)
  double? distanceTo(AddressModel other) {
    if (!hasCoordinates || !other.hasCoordinates) return null;
    
    // Simple distance calculation (Euclidean)
    // Trong thực tế nên dùng Haversine formula
    final latDiff = latitude! - other.latitude!;
    final lonDiff = longitude! - other.longitude!;
    return (latDiff * latDiff + lonDiff * lonDiff);
  }

  // Method để tạo địa chỉ từ form data
  static AddressModel fromFormData({
    String? id,
    String? name,
    String? phone,
    String? street,
    String? ward,
    String? district,
    String? city,
    String? detail,
    String? note,
    String? label,
    String? userId,      // Đổi thành nullable
    bool isDefault = false,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? '',
      name: name ?? label,
      phone: phone,
      street: street,
      ward: ward,
      district: district,
      city: city,
      detail: detail,
      note: note,
      label: label ?? name,
      isDefault: isDefault,
      userId: userId,    // Có thể null
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
  }
}

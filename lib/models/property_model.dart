import 'package:hive/hive.dart';

part 'property_model.g.dart';

@HiveType(typeId: 1)
class Property {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String price;

  @HiveField(5)
  final List<String> images;

  @HiveField(6)
  final String? bhk;

  @HiveField(7)
  final String? bathrooms;

  @HiveField(8)
  final String? carpetArea;

  @HiveField(9)
  final String? sbua;

  @HiveField(10)
  final String? parking;

  @HiveField(11)
  final String? ownerPhone;

  @HiveField(12)
  final String? alternatePhone;

  @HiveField(13)
  final String? mapUrl;

  @HiveField(14)
  final String? description;

  @HiveField(15)
  final String? propertyType;

  @HiveField(16)
  final bool? lift;

  @HiveField(17)
  final bool? coupleFriendly;

  @HiveField(18)
  final bool? independent;

  @HiveField(19)
  final bool? muslimAllowed;

  // -------------------- NEW FIELDS --------------------

  @HiveField(20)
  final String? floor; // Floor / Total Floor

  @HiveField(21)
  final String? removedBigha = null;

  @HiveField(22)
  final String? removedKatha = null;

  @HiveField(23)
  final String? removedLessa = null;

  @HiveField(24)
  final String? removedPricePerBigha = null;

  @HiveField(25)
  final String? removedPricePerKatha = null;

  @HiveField(26)
  final String? removedPricePerLessa = null;

  @HiveField(27)
  final String? ownerName;

  @HiveField(28)
  final String? customLocation; // Optional custom location

  @HiveField(29)
  final String? apartmentType; // Yes / No

  @HiveField(30)
  final String? propertyAge; // In years

  @HiveField(31)
  final String? handoverDate; // Only when Under Construction

  @HiveField(32)
  final String? pricePerSqft; // Price per square foot

  @HiveField(33)
  final String? furnishing; // Furnishing status

  @HiveField(34)
  final String propertyId;

  @HiveField(35)
  final int? priceCategoryMax; // rupees, null = no limit

  @HiveField(36)
  bool isAvailable;

  @HiveField(37)
  final String? landType;

  @HiveField(38)
  final String? landArea;

  @HiveField(39)
  final String? landAreaUnit;

  @HiveField(40)
  final String? landAreaSqft;

  @HiveField(41)
  final String? commercialType;

  @HiveField(42)
  final String? commercialSection;

  @HiveField(43)
  final String? shopNumber;

  @HiveField(44)
  final String? frontage;

  @HiveField(45)
  final String? totalSpace;

  @HiveField(46)
  final List<String>? videos;

  // -----------------------------------------------------

  Property({
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    required this.price,
    required this.images,
    this.bhk,
    this.bathrooms,
    this.carpetArea,
    this.sbua,
    this.parking,
    this.ownerPhone,
    this.alternatePhone,
    this.mapUrl,
    this.description,
    this.propertyType,
    this.lift,
    this.coupleFriendly,
    this.independent,
    this.muslimAllowed,
    this.floor,

    this.ownerName,
    this.customLocation,
    this.apartmentType,
    this.propertyAge,
    this.handoverDate,
    this.pricePerSqft,
    this.furnishing,
    this.propertyId =
        "", // ✅ DEFAULT VALUE (KEY FIX)required this.propertyId, // 👈 ADD
    this.priceCategoryMax,
    this.isAvailable = true,
    this.landType,
    this.landArea,
    this.landAreaUnit,
    this.landAreaSqft,
    this.commercialType,
    this.commercialSection,
    this.shopNumber,
    this.frontage,
    this.totalSpace,
    this.videos,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "title": title,
    "location": location,
    "price": price,
    "images": images,
    "bhk": bhk,
    "bathrooms": bathrooms,
    "parking": parking,
    "ownerPhone": ownerPhone,
    "alternatePhone": alternatePhone,
    "propertyType": propertyType,
    "lift": lift,
    "coupleFriendly": coupleFriendly,
    "independent": independent,
    "muslimAllowed": muslimAllowed,
    "sbua": sbua,
    "carpetArea": carpetArea,
    "floor": floor,

    "mapUrl": mapUrl,
    "description": description,
    "ownerName": ownerName,
    "customLocation": customLocation,
    "apartmentType": apartmentType,
    "propertyAge": propertyAge,
    "handoverDate": handoverDate,
    "furnishing": furnishing,
    "pricePerSqft": pricePerSqft,
    'propertyId': propertyId,
    "isAvailable": isAvailable,
    "landType": landType,
    "landArea": landArea,
    "landAreaUnit": landAreaUnit,
    "landAreaSqft": landAreaSqft,
    "commercialType": commercialType,
    "commercialSection": commercialSection,
    "shopNumber": shopNumber,
    "frontage": frontage,
    "totalSpace": totalSpace,
    "videos": videos,
  };

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json["id"],
    category: json["category"],
    title: json["title"],
    location: json["location"],
    price: json["price"],
    images: List<String>.from(json["images"] ?? []),
    bhk: json["bhk"],
    bathrooms: json["bathrooms"],
    parking: json["parking"],
    ownerPhone: json["ownerPhone"],
    alternatePhone: json["alternatePhone"],
    propertyType: json["propertyType"],
    lift: json["lift"],
    coupleFriendly: json["coupleFriendly"],
    independent: json["independent"],
    muslimAllowed: json["muslimAllowed"],
    sbua: json["sbua"],
    carpetArea: json["carpetArea"],
    floor: json["floor"],

    mapUrl: json["mapUrl"],
    description: json["description"],
    ownerName: json["ownerName"],
    customLocation: json["customLocation"],
    apartmentType: json["apartmentType"],
    propertyAge: json["propertyAge"],
    handoverDate: json["handoverDate"],
    furnishing: json["furnishing"],
    pricePerSqft: json["pricePerSqft"],
    propertyId: json['propertyId'] ?? "",
    isAvailable: json["isAvailable"] ?? true,
    landType: json["landType"],
    landArea: json["landArea"],
    landAreaUnit: json["landAreaUnit"],
    landAreaSqft: json["landAreaSqft"],
    commercialType: json["commercialType"],
    commercialSection: json["commercialSection"],
    shopNumber: json["shopNumber"],
    frontage: json["frontage"],
    totalSpace: json["totalSpace"],
    videos: json["videos"] != null ? List<String>.from(json["videos"]) : [],
  );
  Property copyWith({
    List<String>? images,
    String? propertyId,
    bool? isAvailable,
    String? landType,
    String? landArea,
    String? landAreaUnit,
    String? landAreaSqft,
    String? commercialType,
    String? commercialSection,
    String? shopNumber,
    String? frontage,
    String? totalSpace,
    List<String>? videos,
  }) {
    return Property(
      id: id,
      category: category,
      title: title,
      location: location,
      price: price,
      images: images ?? this.images,
      bhk: bhk,
      bathrooms: bathrooms,
      parking: parking,
      ownerPhone: ownerPhone,
      alternatePhone: alternatePhone,
      propertyType: propertyType,
      lift: lift,
      coupleFriendly: coupleFriendly,
      independent: independent,
      muslimAllowed: muslimAllowed,
      sbua: sbua,
      carpetArea: carpetArea,
      floor: floor,

      mapUrl: mapUrl,
      description: description,
      ownerName: ownerName,
      customLocation: customLocation,
      apartmentType: apartmentType,
      propertyAge: propertyAge,
      handoverDate: handoverDate,
      furnishing: furnishing,
      pricePerSqft: pricePerSqft,
      propertyId: propertyId ?? this.propertyId, // ✅ FIX
      isAvailable: isAvailable ?? this.isAvailable , 
      landType: landType ?? this.landType,
      landArea: landArea ?? this.landArea,
      landAreaUnit: landAreaUnit ?? this.landAreaUnit,
      landAreaSqft: landAreaSqft ?? this.landAreaSqft,
      commercialType: commercialType ?? this.commercialType,
      commercialSection: commercialSection ?? this.commercialSection,
      shopNumber: shopNumber ?? this.shopNumber,
      frontage: frontage ?? this.frontage,
      totalSpace: totalSpace ?? this.totalSpace,
      videos: videos ?? this.videos,
    );
  }

  // ---------- SAFE HELPERS ----------
  String safeDash(String? value) {
    if (value == null || value.trim().isEmpty) return "-";
    return value.trim();
  }

  String safe(String? value) {
    return (value ?? "").trim();
  }
}

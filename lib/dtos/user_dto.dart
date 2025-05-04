class UserDto {
  final int id;
  final int? userAddressId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final int? point;
  final String? address;

  UserDto({
    required this.id,
    this.userAddressId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.point,
    this.address,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userAddressId: json['userAddressId'] != null
          ? int.tryParse(json['userAddressId'].toString())
          : null,
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      point:
          json['point'] != null ? int.tryParse(json['point'].toString()) : null,
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAddressId': userAddressId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'point': point,
      'address': address,
    };
  }

  UserDto copyWith({int? id, String? fullName, String? email, int? point}) {
    return UserDto(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      point: point ?? this.point,
    );
  }
}

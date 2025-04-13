class RegisterRequestDto {
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? deliveryAddress;
  final String password;
  final String role;

  RegisterRequestDto({
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.deliveryAddress,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'deliveryAddress': deliveryAddress,
        'rawPassword': password,
        'role': role,
      };
}

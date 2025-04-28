class RegisterRequestDto {
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String password;
  final String role;
  final String address;
  final String otp;

  RegisterRequestDto({
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.password,
    required this.role,
    required this.address,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'rawPassword': password,
        'role': role,
        'address': address,
        'otp': otp,
      };
}

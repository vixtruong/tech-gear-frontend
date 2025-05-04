class EditProfileDto {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;

  EditProfileDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}

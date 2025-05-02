class ChangePasswordDto {
  final int userId;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordDto({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

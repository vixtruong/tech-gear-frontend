class LoginRequestDto {
  String email;
  String password;

  LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

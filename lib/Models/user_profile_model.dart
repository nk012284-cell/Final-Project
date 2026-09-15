class UserProfileResponse {
  final int id;
  final String email;
  final String? fullName;
  final String? firstName;
  final String? phoneNumber;
  final String? language;
  final String? avatarUrl;
  final bool onboardingCompleted;

  const UserProfileResponse({
    required this.id,
    required this.email,
    this.fullName,
    this.firstName,
    this.phoneNumber,
    this.language,
    this.avatarUrl,
    required this.onboardingCompleted,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        id: (json["id"] as num).toInt(),
        email: json["email"] as String? ?? "",
        fullName: json["fullName"] as String?,
        firstName: json["firstName"] as String?,
        phoneNumber: json["phoneNumber"] as String?,
        language: json["language"] as String?,
        avatarUrl: json["avatarUrl"] as String?,
        onboardingCompleted: json["onboardingCompleted"] as bool? ?? false,
      );
}

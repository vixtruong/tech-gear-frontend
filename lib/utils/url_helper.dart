class UrlHelper {
  static String getGoogleDriveImageUrl(String originalUrl) {
    RegExp regExp = RegExp(r"/d/([a-zA-Z0-9_-]+)");
    Match? match = regExp.firstMatch(originalUrl);
    if (match != null) {
      String fileId = match.group(1)!;
      return "https://drive.google.com/uc?export=view&id=$fileId";
    }
    return originalUrl;
  }
}

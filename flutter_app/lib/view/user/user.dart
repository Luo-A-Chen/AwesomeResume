import 'user_cookie.dart';

class User {
  User._fromCookieJson(Map<String, dynamic> cookieJson)
      : userCookie = UserCookie.fromJson(cookieJson);

  static User? instance;

  final UserCookie userCookie;
}

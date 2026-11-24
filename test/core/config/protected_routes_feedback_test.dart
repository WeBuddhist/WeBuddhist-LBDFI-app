import 'package:flutter_pecha/core/config/protected_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feedback is protected, so the token is always attached', () {
    // Without the token the backend answers 403 "Not authenticated".
    expect(ProtectedRoutes.isProtected('/feedback'), isTrue);
    expect(ProtectedRoutes.isOptional('/feedback'), isFalse);
  });

  test('text requests are protected, so the token is always attached', () {
    // The server needs the signed-in user to accept and rate-limit a request.
    expect(ProtectedRoutes.isProtected('/text-requests'), isTrue);
    expect(ProtectedRoutes.isOptional('/text-requests'), isFalse);
  });
}

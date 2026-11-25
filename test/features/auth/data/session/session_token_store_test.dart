import 'dart:convert';

import 'package:flutter_pecha/features/auth/data/session/session_token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  const first = SessionTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
  const second = SessionTokens(
    accessToken: 'access-2',
    refreshToken: 'refresh-2',
  );

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('nothing stored reads as no session', () async {
    expect(await SecureSessionTokenStore(storage).read(), isNull);
  });

  test('a written pair is read back by a new store (next launch)', () async {
    await SecureSessionTokenStore(storage).write(first);

    final tokens = await SecureSessionTokenStore(storage).read();

    expect(tokens?.accessToken, 'access-1');
    expect(tokens?.refreshToken, 'refresh-1');
  });

  test('the pair is one stored value, so it is replaced whole', () async {
    final store = SecureSessionTokenStore(storage);
    await store.write(first);
    await store.write(second);

    // One entry: there is no moment when one account's access token sits
    // beside another's refresh token.
    final all = await storage.readAll();
    expect(all.keys, [SecureSessionTokenStore.sessionKey]);
    expect(jsonDecode(all.values.single), {
      'access_token': 'access-2',
      'refresh_token': 'refresh-2',
    });
  });

  test('clear removes the session for the next launch too', () async {
    final store = SecureSessionTokenStore(storage);
    await store.write(first);

    await store.clear();

    expect(await store.read(), isNull);
    expect(await SecureSessionTokenStore(storage).read(), isNull);
  });

  test('a stored value that is not a complete pair is no session', () async {
    for (final broken in [
      'not json',
      '[]',
      '{"access_token":"a"}',
      '{"access_token":"","refresh_token":"r"}',
      '{"access_token":"a","refresh_token":7}',
    ]) {
      FlutterSecureStorage.setMockInitialValues({
        SecureSessionTokenStore.sessionKey: broken,
      });
      expect(
        await SecureSessionTokenStore(storage).read(),
        isNull,
        reason: broken,
      );
    }
  });

  test('later reads come from memory, not the keystore', () async {
    final store = SecureSessionTokenStore(storage);
    await store.write(first);

    // Gone from the keystore behind the store's back.
    FlutterSecureStorage.setMockInitialValues({});

    expect((await store.read())?.accessToken, 'access-1');
  });
}

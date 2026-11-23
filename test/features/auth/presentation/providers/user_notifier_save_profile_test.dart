import 'package:flutter_pecha/core/error/failures.dart';
import 'package:flutter_pecha/features/auth/domain/entities/account_names.dart';
import 'package:flutter_pecha/features/auth/domain/entities/user.dart';
import 'package:flutter_pecha/features/auth/domain/usecases/update_user_info_usecase.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/user_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../reader/fakes/fake_local_storage.dart';
import 'auth_notifier_test.mocks.dart';

void main() {
  late MockGetCurrentUserUseCase getUser;
  late MockUpdateUserInfoUseCase updateUserInfo;
  late UserNotifier notifier;

  provideDummy<Either<Failure, User>>(const Left(UnknownFailure('dummy')));

  setUp(() {
    getUser = MockGetCurrentUserUseCase();
    updateUserInfo = MockUpdateUserInfoUseCase();
    notifier = UserNotifier(
      getCurrentUserUseCase: getUser,
      updateUserInfoUseCase: updateUserInfo,
      updateUsernameUseCase: MockUpdateUsernameUseCase(),
      uploadAvatarUseCase: MockUploadAvatarUseCase(),
      localStorageService: FakeLocalStorage(),
    );
  });

  tearDown(() => notifier.dispose());

  UpdateUserInfoParams sentParams() =>
      verify(updateUserInfo(captureAny)).captured.single
          as UpdateUserInfoParams;

  test('saving a display name keeps the first and last name', () async {
    const user = User(id: 'u1', firstName: 'Tenzin', lastName: 'Dhakar');
    when(getUser(any)).thenAnswer((_) async => const Right(user));
    when(updateUserInfo(any)).thenAnswer(
      (_) async => Right(user.copyWith(displayName: 'Tenzin')),
    );
    await notifier.initializeUser();

    final error = await notifier.saveProfile(displayName: 'Tenzin');

    expect(error, isNull);
    final params = sentParams();
    expect(params.firstName, 'Tenzin');
    expect(params.lastName, 'Dhakar');
    expect(params.displayName, 'Tenzin');
  });

  group('an account still on the placeholder name it was created with', () {
    // A phone sign-up, or a provider that shared no name.
    final user = User(
      id: 'u1',
      firstName: AccountNames.placeholder.first,
      lastName: AccountNames.placeholder.last,
    );

    setUp(() {
      when(getUser(any)).thenAnswer((_) async => Right(user));
      when(updateUserInfo(any)).thenAnswer((_) async => Right(user));
    });

    test('takes its first and last name from the display name typed', () async {
      await notifier.initializeUser();

      // What the onboarding step "What should we call you?" saves.
      await notifier.saveProfile(displayName: 'Pema Lhamo Dolkar');

      final params = sentParams();
      expect(params.firstName, 'Pema');
      expect(params.lastName, 'Lhamo Dolkar');
      expect(params.displayName, 'Pema Lhamo Dolkar');
    });

    test('a one-word display name stands for both', () async {
      await notifier.initializeUser();

      await notifier.saveProfile(displayName: 'Pema');

      final params = sentParams();
      expect(params.firstName, 'Pema');
      expect(params.lastName, 'Pema');
    });
  });

  test('a real name that happens to share one half is left alone', () async {
    final user = User(
      id: 'u1',
      firstName: 'Tenzin',
      lastName: AccountNames.placeholder.last,
    );
    when(getUser(any)).thenAnswer((_) async => Right(user));
    when(updateUserInfo(any)).thenAnswer((_) async => Right(user));
    await notifier.initializeUser();

    await notifier.saveProfile(displayName: 'Someone Else');

    final params = sentParams();
    expect(params.firstName, 'Tenzin');
    expect(params.lastName, AccountNames.placeholder.last);
  });

  test('a user without first and last name sends empty strings', () async {
    const user = User(id: 'u1');
    when(getUser(any)).thenAnswer((_) async => const Right(user));
    when(updateUserInfo(any)).thenAnswer((_) async => const Right(user));
    await notifier.initializeUser();

    await notifier.saveProfile(displayName: 'Tenzin');

    final params = sentParams();
    expect(params.firstName, '');
    expect(params.lastName, '');
  });
}

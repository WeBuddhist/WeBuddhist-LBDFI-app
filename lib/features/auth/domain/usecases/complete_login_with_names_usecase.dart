import 'package:flutter_pecha/core/error/failures.dart';
import 'package:flutter_pecha/features/auth/domain/entities/auth_credentials.dart';
import 'package:flutter_pecha/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pecha/shared/domain/base_classes/usecase.dart';
import 'package:fpdart/fpdart.dart';

/// Finishes a sign-in that stopped because a new account needs a first and
/// last name.
class CompleteLoginWithNamesUseCase
    extends UseCase<AuthCredentials, CompleteLoginWithNamesParams> {
  final AuthRepository _repository;

  CompleteLoginWithNamesUseCase(this._repository);

  @override
  Future<Either<Failure, AuthCredentials>> call(
    CompleteLoginWithNamesParams params,
  ) {
    return _repository.completeLoginWithNames(
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }

  /// Drops the waiting sign-in instead.
  void cancel() => _repository.cancelPendingLogin();
}

class CompleteLoginWithNamesParams {
  const CompleteLoginWithNamesParams({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

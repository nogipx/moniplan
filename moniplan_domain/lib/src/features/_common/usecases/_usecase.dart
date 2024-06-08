import 'dart:async';

abstract interface class IUseCase<T> {
  const IUseCase();
  T run();
}

abstract interface class IUseCaseAsync<T> extends IUseCase<FutureOr<T>> {}

export './types/unknown_directory_error.dart';

sealed class Result<T, E> {
  const Result();
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E error;
  const Err(this.error);
}

import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/faliure.dart';

typedef FuterEither<T> = Future<Either<Failuer, T>>;
typedef FutureVoid = FuterEither<void>;

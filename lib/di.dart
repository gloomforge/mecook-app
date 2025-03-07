import 'package:get_it/get_it.dart';
import 'package:mecook_application/features/auth/data/repositories/auth_repository.dart';
import 'package:mecook_application/features/recipes/data/repositories/dish_repository.dart';
import 'package:mecook_application/features/recipes/data/repositories/favorites_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<DishRepository>(() => DishRepository());
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepository());
}

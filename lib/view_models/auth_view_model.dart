import '../repositories/auth_repository.dart';
import '../storage/token_storage.dart';
import '../repositories/favorites_repository.dart';
import '../models/dish.dart';

class AuthViewModel {
  String? token;
  bool loading = false;
  final AuthRepository repository = AuthRepository();
  final TokenStorage tokenStorage = TokenStorage();
  List<int> favoriteDishIds = [];
  String _translateError(String error) {
    if (error.contains("Неверный логин или пароль")) {
      return "Неверный логин или пароль";
    } else if (error.contains("Ошибка регистрации")) {
      return "Ошибка регистрации";
    } else if (error.contains("user already exists")) {
      return "Пользователь уже существует";
    }
    return error;
  }

  Future<String?> login(String identifier, String password) async {
    loading = true;
    var result = await repository.login(identifier, password);
    loading = false;
    if (result.containsKey("token")) {
      token = result["token"];
      await tokenStorage.writeToken(token!);
      await loadFavoriteDishes();
      return null;
    }
    return _translateError(result["error"] ?? "Ошибка входа");
  }

  Future<String?> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    loading = true;
    var result = await repository.register(
      username,
      email,
      password,
      confirmPassword,
    );
    loading = false;
    if (result.containsKey("success") && result["success"] == true) {
      return null;
    }
    return _translateError(result["error"] ?? "Ошибка регистрации");
  }

  Future<void> loadToken() async {
    token = await tokenStorage.readToken();
  }

  Future<void> logout() async {
    token = null;
    favoriteDishIds = [];
    await tokenStorage.deleteToken();
  }

  Future<void> loadFavoriteDishes() async {
    if (token != null) {
      final repo = FavoritesRepository();
      List<Dish>? favorites = await repo.fetchFavoriteDishes(token!);
      if (favorites != null) {
        favoriteDishIds = favorites.map((d) => d.id).toList();
      }
    }
  }
}

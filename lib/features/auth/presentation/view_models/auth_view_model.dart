import 'package:mecook_application/features/auth/data/repositories/auth_repository.dart';
import 'package:mecook_application/core/storage/token_storage.dart';
import 'package:mecook_application/features/recipes/data/repositories/favorites_repository.dart';
import 'package:mecook_application/features/recipes/data/models/dish.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  String? token;
  bool loading = false;
  final AuthRepository repository = AuthRepository();
  final TokenStorage tokenStorage = TokenStorage();
  
  List<int> favoriteDishIds = [];
  List<Dish> favoriteDishes = [];

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  String _translateError(String error) {
    if (error.contains("Неверный логин или пароль")) {
      return "Неверный логин или пароль. Пожалуйста, проверьте введенные данные.";
    } 
    
    else if (error.contains("Incorrect password") || error.contains("wrong password") || 
            error.contains("Invalid credentials")) {
      return "Неверный пароль. Пожалуйста, проверьте правильность ввода.";
    } else if (error.contains("User not found") || error.contains("user does not exist") ||
               error.contains("Пользователь не найден")) {
      return "Пользователь не найден. Проверьте логин или зарегистрируйтесь.";
    } else if (error.contains("Account is blocked") || error.contains("blocked") ||
               error.contains("Аккаунт заблокирован") || error.contains("доступ запрещен") ||
               error.contains("Forbidden")) {
      return "Аккаунт заблокирован. Пожалуйста, обратитесь в службу поддержки.";
    }
    
    else if (error.contains("Ошибка регистрации")) {
      if (error.contains("email") && (error.contains("exists") || error.contains("уже существует"))) {
        return "Этот email уже зарегистрирован. Пожалуйста, используйте другой адрес.";
      } else if (error.contains("username") && (error.contains("exists") || error.contains("уже существует"))) {
        return "Это имя пользователя уже занято. Пожалуйста, выберите другое.";
      } else if (error.contains("password") && (error.contains("match") || error.contains("совпадают"))) {
        return "Пароли не совпадают. Пожалуйста, проверьте ввод.";
      } else if (error.contains("password") && (error.contains("weak") || error.contains("short") ||
                error.contains("короткий") || error.contains("простой"))) {
        return "Пароль слишком простой. Используйте не менее 6 символов, включая буквы и цифры.";
      } else {
        return "При регистрации произошла ошибка. Пожалуйста, проверьте введенные данные."; 
      }
    } 
    
    else if (error.contains("Username already exists") || error.contains("username already exists") ||
            error.contains("Имя пользователя уже занято") || 
            (error.contains("Пользователь") && error.contains("уже существует"))) {
      return "Пользователь с таким именем уже существует. Пожалуйста, выберите другое имя.";
    } 
    
    return error;
  }

  Future<String?> login(String identifier, String password) async {
    loading = true;
    var result = await repository.login(identifier, password);
    loading = false;
    if (result["error"] == "no_connection") {
      return "no_connection";
    }
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
    
    if (result["error"] == "no_connection") {
      return "no_connection";
    }
    
    if (result.containsKey("success") && result["success"] == true) {
      return null;
    }
    
    if (result.containsKey("token") || 
        result.containsKey("user") || 
        result.containsKey("id") ||
        (result.containsKey("message") && (
          result["message"].toString().toLowerCase().contains("успешно") || 
          result["message"].toString().toLowerCase().contains("success")
        ))) {
      return null;
    }
    
    if (result.containsKey("userId") || result.containsKey("username")) {
      return null;
    }
    
    if (result.containsKey("token")) {
      token = result["token"];
      await tokenStorage.writeToken(token!);
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
    favoriteDishes = [];
    await tokenStorage.deleteToken();
    notifyListeners();
  }

  Future<void> loadFavoriteDishes() async {
    if (token != null) {
      final repo = FavoritesRepository();
      List<Dish> loaded = await repo.fetchFavoriteDishes(token!) ?? [];
      favoriteDishes = loaded;
      favoriteDishIds = loaded.map((d) => d.id).toList();
      notifyListeners();
    }
  }
  
  bool isDishFavorite(int dishId) {
    return favoriteDishIds.contains(dishId);
  }

  Future<bool> toggleFavorite(Dish dish) async {
    if (token == null) return false;
    
    final repo = FavoritesRepository();
    
    if (isDishFavorite(dish.id)) {
      final success = await repo.removeFavoriteDish(token!, dish.id);
      if (success) {
        favoriteDishIds.remove(dish.id);
        favoriteDishes.removeWhere((d) => d.id == dish.id);
        notifyListeners();
        return true;
      }
    } else {
      final success = await repo.addFavoriteDish(token!, dish.id);
      if (success) {
        favoriteDishIds.add(dish.id);
        favoriteDishes.add(dish);
        notifyListeners();
        return true;
      }
    }
    
    return false;
  }
}

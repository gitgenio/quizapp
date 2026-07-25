import '../../../data/models/app_user.dart';
import '../../../data/models/enums/user_role.dart';
import '../../../data/repositories/auth_repository.dart';

/// Controla el estado de autenticación del usuario actual.
class AuthController {
  AuthController({
    AuthRepository? authRepository,
  }) : _authRepository =
      authRepository ?? const AuthRepository();

  final AuthRepository _authRepository;

  AppUser? _currentUser;

  /// Usuario actualmente autenticado.
  AppUser? get currentUser => _currentUser;

  /// Indica si existe un usuario autenticado.
  bool get isAuthenticated => _currentUser != null;

  /// Carga el perfil del usuario autenticado.
  ///
  /// Retorna el usuario encontrado o null si no existe
  /// una sesión o perfil.
  Future<AppUser?> loadCurrentUser() async {
    _currentUser =
    await _authRepository.getCurrentUserProfile();

    return _currentUser;
  }

  /// Cierra la sesión y limpia el usuario actual.
  Future<void> signOut() async {
    await _authRepository.signOut();

    _currentUser = null;
  }

  /// Indica si el usuario actual es SuperAdmin.
  bool get isSuperAdmin {
    return _currentUser?.role == UserRole.superAdmin;
  }

  /// Indica si el usuario actual es administrador.
  bool get isAdministrator {
    return _currentUser?.role == UserRole.administrator;
  }
}

/// Instancia global del controlador de autenticación.
final authController = AuthController();
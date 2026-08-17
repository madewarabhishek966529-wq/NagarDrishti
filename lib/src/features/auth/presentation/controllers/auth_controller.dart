import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> loginCitizenEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signInWithEmailAndPassword(email, password));
  }

  Future<void> loginCitizenPhone(String phoneNumber, String otp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signInWithMockPhone(phoneNumber, otp));
  }

  Future<void> loginDepartmentAdmin(String email, String password, String departmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signInAsDepartmentAdmin(email, password, departmentId));
  }

  Future<void> loginCsoZonalOfficer(String email, String password, String zoneId, String zoneName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signInAsCsoZonalOfficer(email, password, zoneId, zoneName));
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

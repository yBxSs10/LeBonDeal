import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';
import '../../features/auth/di/auth_di.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() {
  // Configurer l'injection de dépendances générée
  $initGetIt(getIt);
  
  // Configurer les dépendances d'authentification
  configureAuthDependencies();
}

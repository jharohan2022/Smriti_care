import 'bootstrap.dart';
import 'core/config/flavor_config.dart';
import 'main_patient.dart';

/// ASHA flavor entrypoint (can also run main_patient.dart with dynamic switching):
void main() => bootstrap(
      config: const FlavorConfig(
        flavor: AppFlavor.asha,
        apiBaseUrl: String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080'),
        appTitle: 'SmritiCare — ASHA',
      ),
      appBuilder: () => const SmritiCareApp(),
    );

typedef AshaApp = SmritiCareApp;


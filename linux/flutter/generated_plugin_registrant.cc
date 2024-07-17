//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <tflite_flutter_plus/tflite_flutter_plus_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) tflite_flutter_plus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TfliteFlutterPlusPlugin");
  tflite_flutter_plus_plugin_register_with_registrar(tflite_flutter_plus_registrar);
}

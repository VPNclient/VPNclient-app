//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <url_launcher_windows/url_launcher_windows.h>
#include <vpnclient_engine_flutter/vpnclient_engine_flutter_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  VpnclientEngineFlutterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VpnclientEngineFlutterPluginCApi"));
}

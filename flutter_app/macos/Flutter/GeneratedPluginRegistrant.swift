//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import path_provider_foundation
import screen_brightness_macos
import shared_preferences_foundation
import sqflite_darwin
import video_player_avfoundation
import volume_controller

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenBrightnessMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenBrightnessMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
  VolumeControllerPlugin.register(with: registry.registrar(forPlugin: "VolumeControllerPlugin"))
}

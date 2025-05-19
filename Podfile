source 'https://cdn.cocoapods.org/'
use_modular_headers!
use_frameworks!
#use_frameworks! :linkage => :static
platform :ios, '15.0'

target 'MIO' do
  pod 'AFNetworking', '4.0.1'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'TTTAttributedLabel'
  pod 'CGLMail', '~> 0.1'
  pod 'SDiPhoneVersion', '~> 1.1.1'
  pod 'DateTools' , '1.7.0'
  pod 'AsyncImageView', '1.6'
  pod 'ActionSheetPicker-3.0', '2.7.4'
  pod 'Haneke', '1.0.2'
  pod 'SDWebImage', '4.1.0'
  pod 'libextobjc/EXTScope', '0.6'
  pod 'Realm', '3.13.1'
  pod 'Firebase', '10.0.0'
  pod 'Firebase/Firestore', '10.0.0'
  pod 'Firebase/Messaging', '10.0.0'
end

post_install do |installer|
  # 1) Excluye arm64 en el simulador (iOS‑simulator)  
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end

  # 2) Fix para BoringSSL-GRPC  
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end

  # 3) Fuerza deployment target 15.0 en todos los pods  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

  # Fix para BoringSSL-GRPC
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end

  # Setea el target de implementación a 15.0 en todos los pods
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

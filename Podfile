# Uncomment the next line to define a global platform for your project

platform :ios, '9.0'

target 'Izumrud' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Izumrud

  # Networking
  pod 'Alamofire'
  pod 'PromiseKit'

  # Data base
  pod 'RealmSwift', '= 10.32.3'

  # UI
  pod 'BxInputController/Common'
  #pod 'BxInputController/Photo' need rights in Info.plist
  
  # XML
  pod 'Fuzi'
  
  # Progress
  pod 'CircularSpinner', :git => 'https://github.com/Byterix/CircularSpinner.git'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

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
  pod 'Charts', :git => 'https://github.com/corteggo/Charts', :tag => 'v3.6.1'
  pod 'BxInputController/Common'
  #pod 'BxInputController/Photo' need rights in Info.plist
  
  # XML
  pod 'Fuzi'
  
  # Progress
  pod 'CircularSpinner', :git => 'https://github.com/Byterix/CircularSpinner.git'

  post_install do |installer|
    # https://stackoverflow.com/questions/60162347/how-to-silence-xcode-11-4-warnings-about-mobilecoreservices-and-assetslibrary
    #installer.pods_project.frameworks_group['iOS']['MobileCoreServices.framework'].remove_from_project
    installer.pods_project.targets.each do |target|
      disable_codesign_for_resource_bundle(target)
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

end

def disable_codesign_for_resource_bundle(target)
  return unless target.respond_to?(:product_type) && target.product_type == 'com.apple.product-type.bundle'

  target.build_configurations.each do |config|
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
end

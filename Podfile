# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'LullabAI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'IQKeyboardManagerSwift'
pod 'Alamofire'
#pod 'MBProgressHUD'
pod 'MBProgressHUD', :git => 'https://github.com/jdg/MBProgressHUD.git', :branch => 'master'
pod 'Kingfisher'
pod 'GoogleSignIn'

  target 'LullabAITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LullabAIUITests' do
    # Pods for testing
  end

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
  
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
             end
        end
 end
  
end

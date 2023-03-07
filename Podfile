# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'A3SetupDefaultData' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # use_frameworks!

  # Pods for A3SetupDefaultData

end

target 'AppBox3' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for AppBox3
  pod 'FirebaseCore', :modular_headers => true
  pod 'Google-Mobile-Ads-SDK'
  pod 'PersonalizedAdConsent'

  target 'AppBox3 Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
end

# Uncomment the next line to define a global platform for your project
platform :ios, '13.4'

target 'Tracker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tracker
  pod 'YandexMobileMetrica', '~> 4.5.0' # Укажи актуальную версию

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.4'
      end
    end
  end
end
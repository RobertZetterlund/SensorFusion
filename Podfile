# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

target 'MetaWearApiTest' do
  pod 'MetaWear', :git => 'https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS.git', :branch => 'develop'
  pod 'MBProgressHUD'
  pod 'StaticDataTableViewController'
  pod 'Zip', git: 'https://github.com/marmelroy/Zip.git', branch: 'swift2.3', submodules: true
  pod 'iOSDFULibrary', '1.0.8'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    # Configure Pod targets for Xcode 8 compatibility
    config.build_settings['SWIFT_VERSION'] = '2.3'
  end
end


use_frameworks!
platform :ios, '11.0'

# 
# https://samwize.com/2017/10/05/adding-playground-to-an-existing-project/
#

target 'MileWallet' do
    pod 'SnapKit'
    pod 'QRCodeReader.swift', :path => '../QRCodeReader'
    pod 'SmileLock', :path => '../Smile-Lock'
    pod 'MileCsaLight', :path => '../mile-cpp-api'
    pod 'MileWalletKit', :path => '../mile-wallet-ios-kit'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        # Workaround for CocoaPods issue: https://github.com/CocoaPods/CocoaPods/issues/7606
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
        
        # Do not need debug information for pods
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        
        # Disable Code Coverage for Pods projects - only exclude ObjC pods
        config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
        
        config.build_settings['SWIFT_VERSION'] = '4.0'
    end
end

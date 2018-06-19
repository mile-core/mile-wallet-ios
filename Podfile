use_frameworks!
platform :ios, '11.1'

# 
# https://samwize.com/2017/10/05/adding-playground-to-an-existing-project/
#

target 'MileWallet' do
    #pod 'Socket.IO-Client-Swift', '~> 13.2.0'
    pod 'KeychainAccess'
    pod 'JSONRPCKit'
    pod 'APIKit'
    pod 'ObjectMapper'
    pod 'SnapKit'
    pod 'EFQRCode', '~> 4.2.2'
    pod 'QRCodeReader.swift', '~> 8.2.0'
    #pod 'MileCsaLight', :git => 'https://bitbucket.org/mile-core/mile-cpp-api' #:path => '../../mile-cpp-api'
    pod 'MileCsaLight', :path => '../../mile-cpp-api'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DYLIB_COMPATIBILITY_VERSION'] = ''
        end
    end
end

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

target 'govn' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for govn
pod 'SwiftyJSON', '~> 4.0'
pod 'Alamofire', '~> 4.7'
pod 'AlamofireImage'
pod 'Kingfisher', '~> 4.8.1'
pod 'FSPagerView'
pod 'ImageSlideshow', '~> 1.7.0'
pod 'ImageSlideshow/Kingfisher'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
# pod 'Firebase/Analytics'
pod "KingfisherWebP"
pod 'PKHUD'
pod 'QRCodeReader.swift'
pod 'SwiftSignatureView', '~> 3.0'
pod 'RSBarcodes_Swift', '~> 5.0.2'
pod "ZKProgressHUD"

end

#
#  Be sure to run `pod spec lint YHRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "YHRefresh"
  s.version      = "0.5.0"
  s.summary      = "A Refresh Framework Written In Swift."  
  s.homepage     = "https://github.com/Detailscool/YHRefresh"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Detailscool" => "detailsli@gmail.com" }
  s.source       = { :git => "https://github.com/Detailscool/YHRefresh.git", :tag => s.version }
  s.social_media_url   = "http://www.jianshu.com/u/5a65c3921bda"
  s.source_files  = "YHRefresh/*.swift"
  s.resources    = "YHRefresh/YHRefresh.bundle/*.png"
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  
end

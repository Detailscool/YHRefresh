#
#  Be sure to run `pod spec lint YHRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "YHRefresh"
  s.version      = "0.1.3"
  s.summary      = "A Refresh Framework Written In Swift."  
  s.homepage     = "https://github.com/Detailscool/YHRefresh"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Detailscool" => "detailsli@gmail.com" }
  s.source       = { :git => "https://github.com/Detailscool/YHRefresh.git", :tag => s.version }
  s.social_media_url   = "http://www.jianshu.com/users/5a65c3921bda/top_articles"
  s.source_files  = "YHRefresh/*.swift"
  s.resources    = "YHRefresh/YHRefresh.bundle"
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  
end

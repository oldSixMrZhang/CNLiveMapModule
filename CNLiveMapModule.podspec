#
# Be sure to run `pod lib lint CNLiveMapModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CNLiveMapModule'
  s.version          = '0.0.1'
  s.summary          = 'iOS 发送位置 组件.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  iOS 发送位置 组件.
                       DESC

  s.homepage         = 'http://bj.gitlab.cnlive.com/ios-team/CNLiveMapModule.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '郭瑞朋' => 'guoruipeng@cnlive.com' }
  s.source           = { :git => 'http://bj.gitlab.cnlive.com/ios-team/CNLiveMapModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  ##################################Module###########################################
      s.subspec 'Module' do |ss|
          ss.source_files = 'CNLiveMapModule/Classes/Module/*.{h,m}'
          ss.dependency 'CNLiveMapModule/Controller'
      end
      #############################################################################
      ##################################Controller#####################################
      s.subspec 'Controller' do |ss|
          ss.source_files = 'CNLiveMapModule/Classes/Controller/*'
          ss.dependency 'CNLiveMapModule/View'
      end
      #############################################################################
      ##################################View###########################################
      s.subspec 'View' do |ss|
          ss.source_files = 'CNLiveMapModule/Classes/View/*.{h,m}'
  #        ss.dependency 'CNLiveMapModule/Model'
      end
      #############################################################################
      ##################################Model###########################################
  #    s.subspec 'Model' do |ss|
  #        ss.source_files = 'CNLiveMapModule/Classes/Model/*.{h,m}'
  #    end
      #############################################################################
      #######自定义前缀文件
      s.prefix_header_file = false
      s.prefix_header_file = 'CNLiveMapModule/Classes/Map_PrefixHeader.pch'
      s.static_framework = true
      s.frameworks = 'UIKit'
       s.resource_bundles = {
         'CNLiveMapModule' => ['CNLiveMapModule/Assets/CNLiveMapModule.xcassets']
       }
      s.dependency 'CNLiveTripartiteManagement/BaiduMapKit'#百度地图SDK
      s.dependency 'CNLiveTripartiteManagement/BMKLocationKit'#定位
      s.dependency 'CNLiveTripartiteManagement/QMUIKit'
      s.dependency 'CNLiveTripartiteManagement/SDWebImage'
      s.dependency 'CNLiveTripartiteManagement/Masonry'
      s.dependency 'CNLiveTripartiteManagement/MJRefresh'
      s.dependency 'CNLiveBaseKit'
      s.dependency 'CNLiveRequestBastKit'
      s.dependency 'CNLiveCommonClass'
      s.dependency 'CNLiveEnvironment'
      s.dependency 'CNLiveCustomUI'
      # 服务层
      s.dependency 'CNLiveServices'
      s.dependency 'CNLiveManager'

end

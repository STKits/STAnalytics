
Pod::Spec.new do |s|
  s.name             = 'STAnalytics'
  s.version          = '0.1.2'
  s.summary          = '埋点库'
  s.description      = <<-DESC
                       数据采集埋点
                       DESC

  s.homepage         = 'https://github.com/STKits/STAnalytics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cnjsyyb' => 'cnjsyyb@163.com' }
  s.source           = { :git => 'https://github.com/STKits/STAnalytics.git', :tag => s.version.to_s }

  s.swift_versions = ['5.0']
  s.ios.deployment_target = '13.0'

#  s.resources             = 'STAnalytics/Assets/*.{png,bundle}'
  s.resource_bundles = {
    'STAnalytics_Privacy' => ['STAnalytics/Classes/PrivacyInfo.xcprivacy']
  }
  
  s.subspec "Core" do |cs|
    cs.source_files = 'STAnalytics/Classes/*.swift'
  end
  
end


Pod::Spec.new do |s|
  s.name         = "KVCBaseHelper"
  s.version      = "1.1"
  s.summary      = "kvc helper"
  s.homepage     = "https://github.com/xuzhiming/KVCBaseHelper"
  s.license      = "MIT"
  s.author       = { "xzm" => "xzm@umshz.com" }
  s.source       = { :git => "https://github.com/xuzhiming/KVCBaseHelper.git", :tag => s.version}
  s.source_files = "KVCBaseHelper/CodableObject.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, '7.0'

end

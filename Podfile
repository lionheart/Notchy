# vim: ft=ruby

platform :ios, '11.2'

use_frameworks!

pod 'LionheartExtensions', '~> 3.9'
pod 'QuickTableView', '~> 2'
pod 'SwiftyUserDefaults', '~> 3'
pod 'SuperLayout'
pod 'Presentr'

target 'Notchy' do
  pod 'Hero'
end

target 'Photo Editor' do
end

target 'Action Extension' do
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    plist_buddy = "/usr/libexec/PlistBuddy"
    plist = "Pods/Target Support Files/#{target}/Info.plist"
    `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities array" "#{plist}"`
    `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities:0 string arm64" "#{plist}"`
  end
end

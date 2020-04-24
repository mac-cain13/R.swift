use_frameworks!

workspace 'ResourceApp'
project 'ResourceApp/ResourceApp'

abstract_target 'Shared' do
  inhibit_all_warnings!

  pod 'R.swift.Library', :git => 'https://github.com/mac-cain13/R.swift.Library.git' # for CI builds
  # pod 'R.swift.Library', :path => '../R.swift.Library' # for development

  target 'ResourceApp' do
    platform :ios, '9.0'

    pod 'SWRevealViewController'
  end
  target 'ResourceAppTests' do
    platform :ios, '9.0'

    pod 'SWRevealViewController'
  end
  target 'ResourceApp-tvOS' do
    platform :tvos, '9.0'
  end
  target 'ResourceApp-watchOS-Extension' do
    platform :watchos, '2.2'
  end
end


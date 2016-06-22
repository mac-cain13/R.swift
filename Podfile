use_frameworks!

workspace 'R.swift'
project 'ResourceApp/ResourceApp'

target 'ResourceApp' do

pod 'R.swift.Library', :path => './R.swift.Library'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end

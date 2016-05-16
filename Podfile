use_frameworks!

workspace 'R.swift'
xcodeproj 'ResourceApp/ResourceApp'

target 'ResourceApp' do

pod 'R.swift.Library', :path => './R.swift.Library'

end

target 'ResourceApp-tvOS' do
  platform :tvos, '9.0'
  pod 'R.swift.Library', :path => './R.swift.Library'
  
end

target 'ResourceAppWatchApp Extension' do
  platform :watchos, '2.0'
  pod 'R.swift.Library', :path => './R.swift.Library'

end

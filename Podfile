use_frameworks!

workspace 'ResourceApp'
project 'ResourceApp/ResourceApp'

abstract_target 'Shared' do

  pod 'R.swift.Library', :git => 'git@github.com:mac-cain13/R.swift.Library.git' # for CI builds
  # pod 'R.swift.Library', :path => '../R.swift.Library' # for development

  target 'ResourceApp' do
    pod 'SWRevealViewController'
  end
  target 'ResourceAppTests' do
    pod 'SWRevealViewController'
  end
  target 'ResourceApp-tvOS'

end


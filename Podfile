use_frameworks!

workspace 'ResourceApp'
project 'ResourceApp/ResourceApp'

abstract_target 'Shared' do
    pod 'R.swift.Library', :git => 'git@github.com:mac-cain13/R.swift.Library.git' # for CI builds
    # pod 'R.swift.Library', :path => '../R.swift.Library' # for development

    abstract_target "iOS" do
        platform :ios, '9.0'
        pod 'SWRevealViewController', :inhibit_warnings => true

        target 'ResourceApp'
        target 'ResourceAppTests'

        target 'ResourceBundleApp'
        target 'ResourceBundleAppTests'
    end

    target 'ResourceApp-tvOS' do
        platform :tvos, '9.0'
    end

    post_install do | installer |
        installer.pods_project.build_configurations.each do | config |

            # build perf improvement. Turn on whole module optimization. Suggested by Xcode
            if config.name.start_with?('Release')
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = "-Owholemodule"
            end
        end
    end
end

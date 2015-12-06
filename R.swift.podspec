Pod::Spec.new do |s|

  s.name         = "R.swift"
  s.version      = "0.13.0.beta.1"
  s.summary      = "Get strong typed, autocompleted resources like images, fonts and segues in Swift projects"

  s.description  = <<-DESC
                   R.swift is a tool to get strong typed, autocompleted resources like images, fonts and segues in Swift projects.

                   * Never type string identifiers again
                   * Supports images, fonts, storyboards, nibs, segues, reuse identifiers and more
                   * Compile time checks and errors instead of runtime crashes
                   DESC

  s.homepage     = "https://github.com/mac-cain13/R.swift"

  s.license      = "MIT"

  s.author             = { "Mathijs Kadijk" => "mkadijk@gmail.com" }
  s.social_media_url   = "https://twitter.com/mac_cain13"

  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '1.0'

  s.source       = { :http => "https://github.com/mac-cain13/R.swift/releases/download/v0.13.0.beta.1/rswift-0.13.0.beta.1.zip" }

  s.preserve_paths = "rswift"

end

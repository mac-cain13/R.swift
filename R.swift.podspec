Pod::Spec.new do |s|

  s.name         = "R.swift"
  s.version      = "0.8.0"
  s.summary      = "Use strong typed, autocompleted resources like images and segues in Swift"

  s.description  = <<-DESC
                   R.swift is a tool to get strong typed, autocompleted resources like images and segues in Swift

                   * Never type string identifiers again
                   * Strong type all the things
                   * Supports images, segues, storyboards, nibs and xibs, reuse identifiers and more
                   * Compile time checks and errors instead of runtime crashes
                   DESC

  s.homepage     = "https://github.com/mac-cain13/R.swift"

  s.license      = "MIT"

  s.author             = { "Mathijs Kadijk" => "mkadijk@gmail.com" }
  s.social_media_url   = "https://twitter.com/mac_cain13"

  s.platform     = :ios, "7.0"

  s.source       = { :http => "https://github.com/mac-cain13/R.swift/releases/download/v0.8.0/rswift-0.8.0.zip" }

  s.preserve_paths = "rswift"

end

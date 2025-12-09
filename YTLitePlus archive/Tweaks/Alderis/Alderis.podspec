Pod::Spec.new do |spec|
  spec.name         = "Alderis"
  spec.version      = "1.2.4"
  spec.summary      = "A fresh new color picker, with a gentle, fun, and dead simple user interface."
  spec.description  = <<-DESC
                      Alderis is a fresh new color picker, with a gentle, fun, and dead simple user
                      interface. It aims to incorporate the usual elements of a color picker, in a way
                      that users will find easy and fun to use.

                      The user can start by selecting a color they like on the initial color palette
                      tab, and either accept it, or refine it using the color wheel and adjustment
                      sliders found on the two other tabs.
                      DESC
  spec.homepage     = "https://github.com/hbang/Alderis"
  spec.screenshots  = "https://github.com/hbang/Alderis/raw/main/screenshots/alderis-1.jpg",
                      "https://github.com/hbang/Alderis/raw/main/screenshots/alderis-2.jpg",
                      "https://github.com/hbang/Alderis/raw/main/screenshots/alderis-3.jpg",
                      "https://github.com/hbang/Alderis/raw/main/screenshots/alderis-4.jpg"
  spec.license      = "Apache License, Version 2.0"
  spec.author       = "HASHBANG Productions"
  spec.social_media_url = "https://twitter.com/hashbang"

  spec.swift_versions = "5.0"
  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/hbang/Alderis.git", :tag => "#{spec.version}" }
  spec.requires_arc = true
  spec.source_files = [ "Alderis/*.swift", "Alderis/*.h" ]
  spec.resource_bundles = { "Alderis" => "Alderis/Assets-ios12.xcassets" }
end

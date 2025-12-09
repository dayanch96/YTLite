Pod::Spec.new do |spec|
  spec.name             = 'Reflex'
  spec.version          = '1.0.0'
  spec.summary          = 'A module that adds support for inspecting Swift objects in FLEX.'
  spec.license          = { :type => 'BSD', :file => 'LICENSE' }

  spec.author           = { 'Tanner Bennett' => 'tannerbennett@me.com' }
  spec.homepage         = 'https://github.com/FLEXTool/Reflex'
  spec.source           = { :git => 'https://github.com/FLEXTool/Reflex.git', :tag => '#{spec.version}' }
  
  spec.dependency       'FLEX', '~> 4.6.0'
  
  spec.platform         = :ios, '12.0'
  spec.source_files     = 'Reflex/*.swift'
  spec.frameworks       = [ 'Foundation' ]
  spec.swift_version    = '5.0'
end

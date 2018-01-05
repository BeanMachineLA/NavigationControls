Pod::Spec.new do |s|

  s.name         = "HamburgerMenu"
  s.version      = "0.1.5"
  s.summary      = "Compilation of views that show remote content"

  s.homepage     = "https://ramotion.com"

  s.license      = {:type => "All rights reserved", :text => "All rights reserved"}

  s.author       = { "Kolpachkov Igor" => "i.kolpachkov@gmail.com" }
 
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/TalntsApp/TalntsNavigationControls.git", :tag => "HamburgerMenu.0.1.5" }

  s.source_files  = "HamburgerMenu", "HamburgerMenu/HamburgerMenu/**/*.{h,m,swift}"

  s.requires_arc = true

  s.frameworks = 'UIKit'

end

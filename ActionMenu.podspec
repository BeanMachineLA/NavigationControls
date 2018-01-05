Pod::Spec.new do |s|

  s.name         = "ActionMenu"
  s.version      = "0.1.4"
  s.summary      = "Compilation of views that show remote content"

  s.homepage     = "https://ramotion.com"

  s.license      = {:type => "All rights reserved", :text => "All rights reserved"}

  s.author       = { "Kolpachkov Igor" => "i.kolpachkov@gmail.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/TalntsApp/TalntsNavigationControls.git", :tag => "ActionMenu.0.1.4" }

  s.source_files  = "ActionMenu", "ActionMenu/ActionMenu/**/*.{h,m,swift}"

  s.requires_arc = true

  s.frameworks = 'UIKit'

end

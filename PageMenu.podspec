Pod::Spec.new do |s|

  s.name         = "PageMenu"
  s.version      = "0.2.3"
  s.summary      = "Compilation of views that show remote content"

  s.homepage     = "https://ramotion.com"

  s.license      = {:type => "All rights reserved", :text => "All rights reserved"}

  s.author       = { "Kolpachkov Igor" => "i.kolpachkov@gmail.com" }

  s.platform     = :ios, "8.3"

  s.source       = { :git => "https://github.com/TalntsApp/TalntsNavigationControls.git", :tag => "PageMenu.#{s.version}" }

  s.source_files  = "PageMenu", "PageMenu/PageMenu/**/*.{h,m,swift}"

  s.requires_arc = true

  s.frameworks = 'UIKit'

end

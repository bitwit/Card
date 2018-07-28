#
# Be sure to run `pod lib lint YogaGloCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Card"
  s.version          = "0.0.1"
  s.summary          = "A consistent API for all types of UIKit lists"
  s.description      = "Populate UITableView, UICollectionView and UIStackView with universal declarative configuration"
  s.license          = "MIT"

  s.homepage         = "http://www.bitwit.ca"
  s.author           = { "Kyle Newsome" => "kyle@bitwit.ca" }
  s.source           = { :git => "https://github.com/bitwit/Card.git", :tag => s.version.to_s }

  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "11.0"
  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
  #s.resource_bundles = {
    #'Card' => ['Pod/Assets/*']
  #}

end

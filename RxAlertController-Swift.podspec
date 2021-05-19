#
# Be sure to run `pod lib lint RxAlertController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxAlertController-Swift'
  s.version          = '1.1.0'
  s.summary          = 'Library for Reactive programming of UIAlertController.'
  s.description      = 'Library for Reactive programming of UIAlertController.'
  s.homepage         = 'https://github.com/pisces/RxAlertController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Steve Kim' => 'hh963103@gmail.com' }
  s.source           = { :git => 'https://github.com/pisces/RxAlertController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'RxAlertController/Classes/**/*'
  s.dependency 'RxSwift'
end

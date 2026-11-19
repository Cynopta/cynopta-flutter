#
# The iOS side of cynopta_flutter for CocoaPods hosts. Swift Package Manager hosts (Flutter's default) use
# cynopta_flutter/Package.swift instead; both take the same vendored Cynopta iOS SDK frameworks.
#
Pod::Spec.new do |s|
  s.name             = 'cynopta_flutter'
  s.version          = '1.0.23'
  s.summary          = 'Flutter plugin for the Cynopta SDK.'
  s.description      = <<-DESC
Flutter plugin for the Cynopta SDK. On iOS it bundles the Cynopta iOS SDK as binary xcframeworks.
                       DESC
  s.homepage         = 'https://cynopta.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Cynopta Ltd' => 'https://cynopta.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'cynopta_flutter/Sources/cynopta_flutter/**/*.swift'
  s.vendored_frameworks = 'cynopta_flutter/Frameworks/*.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

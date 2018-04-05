Pod::Spec.new do |s|
  s.name             = 'JIRAKit'
  s.version          = '1.0.0'
  s.summary          = 'JIRA Kit for iOS written in swift'
  s.homepage         = 'https://github.com/maryamaffinityclick/JIRAKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Maryam Fekri' => 'maryam@affinityclick.com' }
  s.source           = { :git => 'https://github.com/maryamaffinityclick/JIRAKit.git'}
  s.ios.deployment_target = '8.0'
  s.source_files = 'JIRAKit/Classes/**/*'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end

Pod::Spec.new do |s|
  s.name                  = 'GBChat'
  s.version               = '0.1.5'
  s.summary               = 'Objective-C client library for Goonbee\'s chat service, for iOS and OS X.'
  s.homepage              = 'https://github.com/lmirosevic/GBChat'
  s.license               = { type: 'Apache License, Version 2.0', file: 'LICENSE' }
  s.author                = { 'Luka Mirosevic' => 'luka@goonbee.com' }
  s.source                = { git: 'https://github.com/lmirosevic/GBChat.git', tag: s.version.to_s, submodules: true }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.requires_arc          = true
  s.source_files          = 'GBChat.{h,m}', 'thrift/gen-cocoa/GoonbeeChatService.{h,m}'
  s.public_header_files   = 'GBChat.h', 'thrift/gen-cocoa/GoonbeeChatService.h'

  s.dependency 'GBToolbox'
  s.dependency 'GBThriftApi', '~> 0.1'
end

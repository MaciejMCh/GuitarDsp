Pod::Spec.new do |spec|
  spec.name         = 'GuitarMidi'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/MaciejMch/GuitarDsp'
  spec.authors      = { 'Maciej Chmielewski' => 'maciejmch@gmail.com' }
  spec.summary      = 'guitar dsp kit'
  spec.source       = { :git => 'https://github.com/maciejmch/guitardsp.git' }
  spec.osx.deployment_target  = '10.12'
  spec.source_files = 'GuitarMidi/*.swift'
  spec.resources    = 'GuitarMidi/*.storyboard', 'GuitarMidi/Assets.xcassets'
  spec.dependency 'EZAudio'
  spec.dependency 'CubicBezier'
  spec.dependency 'GuitarDsp'
  spec.dependency 'Beethoven'
  spec.dependency 'MIDIKit'
  spec.requires_arc = true
end
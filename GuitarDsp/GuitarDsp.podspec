Pod::Spec.new do |spec|
  spec.name         = 'GuitarDsp'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/MaciejMch/GuitarDsp'
  spec.authors      = { 'Maciej Chmielewski' => 'maciejmch@gmail.com' }
  spec.summary      = 'guitar dsp kit'
  spec.source       = { :git => 'https://github.com/maciejmch/guitardsp.git' }
  spec.osx.deployment_target  = '10.8'
  spec.source_files = 'GuitarDsp/*.{h,m}'
  spec.dependency 'EZAudio'
  spec.requires_arc = true
end
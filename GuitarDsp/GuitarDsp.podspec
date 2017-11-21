Pod::Spec.new do |spec|
  spec.name         = 'GuitarDsp'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/MaciejMch/GuitarDsp'
  spec.authors      = { 'Maciej Chmielewski' => 'maciejmch@gmail.com' }
  spec.summary      = 'guitar dsp kit'
  spec.source       = { :git => 'https://github.com/maciejmch/guitardsp.git' }
  spec.osx.deployment_target  = '10.12'
  spec.ios.deployment_target  = '11.0'
  spec.ios.source_files = 'GuitarDsp/{Board,Processor,AudioInterface,SamplingSettings,Effect,Sample,FrequencyDomainProcessing,Freeverb,Allpass,Comb,denormals}.{h,m}'
  spec.osx.source_files = 'GuitarDsp/*.{h,m}'
  spec.osx.dependency 'EZAudio'
  spec.ios.dependency 'Novocaine'
  spec.requires_arc = true
end
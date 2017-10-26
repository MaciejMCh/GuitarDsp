Pod::Spec.new do |spec|
  spec.name         = 'NodesMap'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/MaciejMch/NodesMap'
  spec.authors      = { 'Maciej Chmielewski' => 'maciejmch@gmail.com' }
  spec.summary      = 'guitar dsp kit'
  spec.source       = { :git => 'https://github.com/maciejmch/nodesmap.git' }
  spec.osx.deployment_target  = '10.12'
  spec.ios.deployment_target  = '11.0'
  spec.osx.source_files = 'NodesMap\ macOS/MapViewController.swift', 'NodesMap Shared/*.{swift}'
  spec.ios.source_files = 'NodesMap\ iOS/MapViewController.swift', 'NodesMap Shared/*.{swift}'
  spec.osx.resources    = 'NodesMap macOS/Map.storyboard', 'NodesMap Shared/Scene.sks'
  spec.ios.resources    = 'NodesMap iOS/Map.storyboard', 'NodesMap Shared/Scene.sks'
  spec.requires_arc = true

end
Pod::Spec.new do |spec|
  spec.name         = 'NodesMap'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/MaciejMch/NodesMap'
  spec.authors      = { 'Maciej Chmielewski' => 'maciejmch@gmail.com' }
  spec.summary      = 'guitar dsp kit'
  spec.source       = { :git => 'https://github.com/maciejmch/nodesmap.git' }
  spec.osx.deployment_target  = '10.12'
  spec.source_files = 'NodesMap\ macOS/MapViewController.swift', 'NodesMap Shared/*.{swift}'
  spec.resources    = 'NodesMap macOS/Map.storyboard', 'NodesMap Shared/Scene.sks'
  spec.requires_arc = true

end
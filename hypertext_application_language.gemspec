File.expand_path('../lib', __FILE__).tap do |path|
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'hypertext_application_language/version'

Gem::Specification.new do |spec|
  spec.name = 'hypertext_application_language'
  spec.version = HypertextApplicationLanguage::VERSION
  spec.summary = %q{Hypertext Application Language}
  spec.description = <<-DESCRIPTION.gsub(/\s+/, ' ').strip
  Suite of Ruby classes for rendering and parsing HAL resource representations,
  including their links, properties and nested representations of embedded
  resources.
  DESCRIPTION
  spec.homepage = 'http://stateless.co/hal_specification.html'
  spec.authors = ['Roy Ratcliffe']
  spec.email = ['roy@pioneeringsoftware.co.uk']
  spec.files = `git ls-files -z`.split("\x0")
  spec.license = 'MIT'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end

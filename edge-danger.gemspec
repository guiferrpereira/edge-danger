require_relative 'lib/edge/danger/version'

Gem::Specification.new do |spec|
  spec.name          = "edge-danger"
  spec.version       = Edge::Danger::VERSION
  spec.authors       = ["guiferrpereira"]
  spec.email         = ["development@edgepetrol.com"]

  spec.summary       = %q{Danger.systems conventions for EdgePetrol projects.}
  spec.description   = %q{Packages a Dangerfile to be used with Danger.}
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = ""
  # spec.metadata["changelog_uri"] = ""

  spec.add_runtime_dependency 'danger', '~> 8.0'

  spec.add_development_dependency 'rspec', '~> 3.2'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end

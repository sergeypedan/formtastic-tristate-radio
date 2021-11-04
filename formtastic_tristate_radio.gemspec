# frozen_string_literal: true

# https://guides.rubygems.org/name-your-gem/
# https://bundler.io/guides/creating_gem.html
# https://guides.rubyonrails.org/engines.html
# https://guides.rubyonrails.org/plugins.html

require_relative "lib/formtastic_tristate_radio/version"

Gem::Specification.new do |spec|
  spec.authors          = ["Sergey Pedan"]
  spec.bindir           =  "exe"
  spec.summary          =  "Have 3-state radiobuttons instead of a 2-state checkbox for your Boolean columns which can store NULL"
  spec.description      =  "#{spec.summary}. Does not change controls, you need to turn it on via `as: :tristate_radio` option."
  spec.email            = ["sergey.pedan@gmail.com"]
  spec.executables      =   spec.files.grep(%r{\A#{spec.bindir}/}) { |f| File.basename(f) }
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  spec.files              = Dir["{app,config,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
# spec.files            =  `git ls-files`.split("\n")
  spec.homepage         =  "https://github.com/sergeypedan/formtastic-tristate-radio"
  spec.license          =  "MIT"
  spec.name             = "formtastic_tristate_radio"
  spec.metadata         = {
    "changelog_uri"     => "#{spec.homepage}/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/#{spec.name}",
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => spec.homepage
  }
  spec.platform         =  Gem::Platform::RUBY
  spec.rdoc_options     = ["--charset=UTF-8"]
  spec.require_paths    = ["lib", "app/inputs", "app/models/active_record", "config/initializers", "config/locales"]
  spec.version          = FormtasticTristateRadio::VERSION

  spec.required_ruby_version     = Gem::Requirement.new(">= 2.4.0")
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  # end

  spec.add_dependency "formtastic", ">= 3", "< 5"
  spec.add_dependency "rails",      ">= 4", "< 7"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "yard",  ">= 0.9", "< 1"
end

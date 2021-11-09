# frozen_string_literal: true

# https://guides.rubygems.org/name-your-gem/
# https://bundler.io/guides/creating_gem.html
# https://guides.rubyonrails.org/engines.html
# https://guides.rubyonrails.org/plugins.html

require_relative "lib/formtastic_tristate_radio/version"

Gem::Specification.new do |spec|
  spec.name             = "formtastic_tristate_radio"
  spec.version          =  FormtasticTristateRadio::VERSION
  spec.authors          = ["Sergey Pedan"]
  spec.email            = ["sergey.pedan@gmail.com"]
  spec.license          =  "MIT"

  spec.summary          =  "Have 3-state radiobuttons instead of a 2-state checkbox for your Boolean columns which can store NULL"
  spec.description      = <<~HEREDOC
                            #{spec.summary}.

                            What the gem does?

                            1. Provides a custom Formtastic input type `:tristate_radio` which renders 3 radios (“Yes”, “No”, “Unset”) instead of a checkbox (only where you put it).
                            1. Teaches Rails recognize `"null"` and `"nil"` param values as `nil`. See “[How it works](#how-it-works)” ☟ section for technical details on this.
                            1. Encourages you to add translations for ActiveAdmin “status tag” so that `nil` be correctly translated as “Unset” instead of “False”.

                            Does not change controls, you need to turn it on via `as: :tristate_radio` option.

                            By defenition Boolean values have 2 states: True & False.

                            However, if you store a Boolean value in a database column with no `NOT NULL` restriction, it aquires a 3<sup>d</sup> possible state: `null`.

                            Some may consider this practice questionable — I don’t think so. In real life you always have a case when the answer to your question may be only “yes” or “no”, but you don’t know the answer yet. Using a string type column, storing there `"yes"`, `"no"` and `"unset"` + using a state machine + validations — feels overkill to me.
                          HEREDOC

  spec.homepage         =  "https://github.com/sergeypedan/formtastic-tristate-radio"
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  spec.rdoc_options     = ["--charset=UTF-8"]
  spec.metadata         = { "changelog_uri"     => "#{spec.homepage}/blob/master/CHANGELOG.md",
                            "documentation_uri" => "https://www.rubydoc.info/gems/#{spec.name}",
                            "homepage_uri"      => spec.homepage,
                            "source_code_uri"   => spec.homepage }

  spec.require_paths    = ["app/inputs", "app/models/active_record", "config/initializers", "config/locales", "lib"]
  spec.bindir           = "exe"
  spec.executables      = []
  spec.files            = Dir.chdir(File.expand_path(__dir__)) do
                            `git ls-files`.split("\n")
                              .reject { |f| %w[bin spec test].any? { |dir| f.start_with? dir } }
                              .reject { |f| f.start_with? "." }
                          end

  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "formtastic", ">= 3", "< 5"
  spec.add_dependency "rails",      ">= 4", "< 7"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "yard",  "~> 0"
end

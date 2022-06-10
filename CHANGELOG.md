# Changelog

## [0.2.7] - 2022-06-10

- Corrects load bug introduced in the previous version (probably due to changed loading behavior in Rails)

## [0.2.6] - 2022-06-10

- Upgrades dependencies in Gemfile.lock

## [0.2.5] - 2021-11-10

- Corrects an error introduced in 0.2.4
- Moves error-related code into a new module
- Type-checks the `unset_value` passed into configuration

## [0.2.4] - 2021-11-09

- Add translations into most popular languages (although the problem with loading them seems to persist)

## [0.2.2] - 2021-11-05

- Make the gem configurable
- Pull the key used for “unset” choice value into configuration

## [0.2.1] - 2021-11-04

- Updates docs URL in gemspec
- Updates change-log URL in gemspec
- Removes development gems
- Adds roadmap items

## [0.2.0] - 2021-11-04

- Custom translation override from form via options
- Custom error class
- YARD documentation for everything
- Inherits from `Formtastic::Inputs::RadioInput` and patches only necessary methods
- Error YAML example for ActiveAdmin included only if ActiveAdmin is detected

## [0.1.0] - 2021-11-01

Initial release

# frozen_string_literal: true

module FormtasticTristateRadio
  module I18n

    EXAMPLE_ACTIVEADMIN = <<~YAML.chomp
      ru:
        active_admin:
          status_tag:
            :yes: Да
            :no: Нет
            :#{FormtasticTristateRadio.config.unset_key}: Неизвестно
    YAML

    EXAMPLE_FORMTASTIC = <<~YAML.chomp
      ru:
        formtastic:
          :yes: Да
          :no: Нет
          :#{FormtasticTristateRadio.config.unset_key}: Неизвестно
    YAML

    class Error < ::I18n::MissingTranslationData
      module Base

        # @note In you have ActiveAdmin installed, it will give you YAML example for ActiveAdmin as well, otherwise only for Formtastic
        #
        # @return [String] error message with YAML examples for the “unset” label translation lookup error
        #
        # @see URL https://github.com/ruby-i18n/i18n/blob/master/lib/i18n/exceptions.rb#L63 Original I18n method
        #
        def message
          msg = []
          msg << "Add translations for the “unset” radio label"
          msg << ["For radiobutton labels in forms:", EXAMPLE_FORMTASTIC].join("\n")
          msg << "Note: “yes”, “no” and some other reserved words are converted into Boolean values in YAML, so you need to quote or symbolize them."
          msg << ["For ActiveAdmin status tags in index & view tables:", EXAMPLE_ACTIVEADMIN].join("\n") if !!defined?(ActiveAdmin)
          [super, msg.join("\n\n")].join("\n\n")
        end
      end

      include Base
    end

  end
end

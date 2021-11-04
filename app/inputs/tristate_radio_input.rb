# frozen_string_literal: true

require "formtastic"

# It may also be appropriate to put this file in `app/inputs`
class TristateRadioInput < Formtastic::Inputs::RadioInput

  # No equals `:null`.
  #
  # Mind ActiveAdmin [status resolving logic](https://github.com/activeadmin/activeadmin/blob/master/lib/active_admin/views/components/status_tag.rb#L51):
  # in status tag builder the value is lowercased before casting into Boolean, and the keyword for nil is `"unset"`.
  # So if we have lowercase `"unset"`, translations from `ru.formtastic.unset` will be overriden by `ru.active_admin.status_tag.unset`.
  #
  UNSET_KEY = ActiveModel::Type::Boolean::NULL_VALUES.reject(&:blank?).first

  I18N_EXAMPLE_ACTIVEADMIN = <<~YAML.chomp
    ru:
      active_admin:
        status_tag:
          :yes: Да
          :no: Нет
          :#{UNSET_KEY}: Неизвестно
  YAML

  I18N_EXAMPLE_FORMTASTIC = <<~YAML.chomp
    ru:
      formtastic:
        :yes: Да
        :no: Нет
        :#{UNSET_KEY}: Неизвестно
  YAML


  # @note In you have ActiveAdmin installed, it will give you YAML example for ActiveAdmin as well, otherwise only for Formtastic
  #
  # @return [String] error message with YAML examples for the “unset” label translation lookup error
  #
  def self.missing_i18n_error_msg
    msg = []
    msg << "Add translations for the “unset” radio label"
    msg << ["For radiobutton labels in forms:", I18N_EXAMPLE_FORMTASTIC].join("\n")
    msg << "Note: “yes”, “no” and some other reserved words are converted into Boolean values in YAML, so you need to quote or symbolize them."
    msg << ["For ActiveAdmin status tags in index & view tables:", I18N_EXAMPLE_ACTIVEADMIN].join("\n") if !!defined?(ActiveAdmin)
    msg.join("\n\n")
  end


  # @see https://github.com/formtastic/formtastic/blob/35dc806964403cb2bb0a6074b951ceef906c8581/lib/formtastic/inputs/base/choices.rb#L59 Original Formtastic method
  #
  # @return [Hash] HTML options for the `<input type="radio" />` tag
  #
  # Adds `{ selected: true }` to the original options Hash if the choice value equals attribute value (to ultimately set for `checked="checked"`)
  #
  def choice_html_options(choice)
    super.merge({ checked: selected?(choice) })
  end


  # @example Original method
  #   def collection_for_boolean
  #     true_text  = options[:true]  || Formtastic::I18n.t(:yes)
  #     false_text = options[:false] || Formtastic::I18n.t(:no)
  #     [ [true_text, true], [false_text, false] ]
  #   end
  #
  #   collection_for_boolean #=> [["Да", true], ["Нет", false]]
  #
  # @example This patched method
  #   collection_for_boolean #=> [["Да", true], ["Нет", false], ["Неизвестно", :null]]
  #
  # @return [Array<[String, (Boolean|String|Symbol)]>] an array of “choices”, each presented as an array with 2 items: HTML label text and HTML input value
  #
  # @see https://github.com/formtastic/formtastic/blob/e34baba470d2fda75bf9748cff8898ee0ed29075/lib/formtastic/inputs/base/collections.rb#L131 Original Formtastic method
  #
  def collection_for_boolean
    super + [[label_text_for_unset, UNSET_KEY]]
  end


  # Checks translation passed as option, then checks in locale
  #
  # @example
  #   label_text_for_unset #=> "Неизвестно"
  #
  # @return [String] Label of the radio that stands for the unknown choice
  #
  # @raise [StandardError] if the translation could not be found
  # @see missing_i18n_error_msg
  #
  def label_text_for_unset
    options.fetch(:null, Formtastic::I18n.t(UNSET_KEY)).presence or \
      fail FormtasticTristateRadio::MissingTranslationError.new(self.class.missing_i18n_error_msg)
  end


  # @example For each item of `collection` it runs:
  #   selected?(["Да", true]) #=> false
  #   selected?(["Нет", false]) #=> false
  #   selected?(["Неизвестно", :null]) #=> true
  #
  # @param choice [Array<[String, (Boolean|String|Symbol)]>]
  #
  # @return [Boolean] answer to the question “Is the passed option selected?”
  #
  # @note For this to work, `ActiveModel::Type::Boolean` must be patched to resolve `UNSET_KEY` as `nil`.
  #
  def selected?(choice)
    ActiveModel::Type::Boolean.new.cast(choice_value(choice)) == object.public_send(method)
  end

end

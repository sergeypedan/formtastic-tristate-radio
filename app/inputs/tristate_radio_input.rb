# frozen_string_literal: true

# It may also be appropriate to put this file in `app/inputs`
class TristateRadioInput < Formtastic::Inputs::RadioInput

  # Now equals `:null`.
  # Should equal one of `ActiveModel::Type::Boolean::NULL_VALUES`
  #
  # Mind ActiveAdmin [status resolving logic](https://github.com/activeadmin/activeadmin/blob/master/lib/active_admin/views/components/status_tag.rb#L51):
  # in status tag builder the value is lowercased before casting into Boolean, and the keyword for nil is `"unset"`.
  # So if we have lowercase `"unset"`, translations from `ru.formtastic.unset` will be overriden by `ru.active_admin.status_tag.unset`.
  #
  UNSET_KEY = FormtasticTristateRadio.config.unset_key


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
    options.fetch(:null, Formtastic::I18n.t(UNSET_KEY)).presence or fail FormtasticTristateRadio::I18n::Error.new(locale, UNSET_KEY)
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

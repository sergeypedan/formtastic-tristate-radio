# frozen_string_literal: true

require "formtastic"

# It may also be appropriate to put this file in `app/inputs`
class TristateRadioInput < Formtastic::Inputs::RadioInput

  # @!attribute [r] method
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   Defined in `Formtastic::Inputs::Base#initialize`
  #
  #   @return [Symbol] the name of the model attribute
  #
  #   @example For `User#is_awesome`
  #     method #=> :is_awesome
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/base.rb#L8 Original Formtastic method


  # @!attribute [r] object
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   Defined in `Formtastic::Inputs::Base#initialize`
  #
  #   @return [ActiveRecord::Base] concrete model subclass
  #
  #   @example
  #     object #=> User
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/base.rb#L8 Original Formtastic method


  # @!attribute [r] template
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   Defined in `Formtastic::Inputs::Base#initialize`
  #
  #   @return [ActionView::Base] Rails template builder
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/base.rb#L8 Original Formtastic method


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
    msg << ["For ActiveAdmin status tags in index & view tables:", I18N_EXAMPLE_ACTIVEADMIN].join("\n") if !!defined?(ActiveAdmin)
    msg << ["For radiobutton labels in forms:", I18N_EXAMPLE_FORMTASTIC].join("\n")
    msg << "Note: “yes”, “no” and some other reserved words are converted into Boolean values in YAML, so you need to quote or symbolize them."
    msg.join("\n")
  end


  # @example How it works under the hood
  #   choice_html(["Да", true])
  #   #=> "<label for=\"model_attribute_true\">
  #   #=>   <input id=\"model_attribute_true\" type=\"radio\" value=\"true\" name=\"model[attribute]\" />
  #   #=>   Да
  #   #=> </label>"
  #
  # @param choice [Array<Label text, choice value>]
  #
  # @return [String] stringified HTML of the <label> tag (with radiobutton and text inside) that stands for the unknown choice.
  #
  def choice_html(choice)
    template.content_tag(:label, input_tag_html(choice), label_tag_options(choice))
  end

  # @!method choice_value(choice)
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   @example
  #     choice_value(["Да", true]) #=> true
  #     choice_value(["Нет", false]) #=> false
  #     choice_value(["Неизвестно", :null]) #=> :null
  #
  #   @example What it does under the hood
  #     choice.is_a?(Array) ? choice[1] : choice
  #
  #   @param choice [Array<[String, (Boolean|String|Symbol)]>]
  #
  #   @return [Any] whichever value is the 2nd of the passed array
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/base/choices.rb#L55 Original Formtastic method


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


  # @example
  #   input_tag_html(["Да", true])
  #   #=> "<input id=\"model_attribute_true\" type=\"radio\" value=\"true\" name=\"model[attribute]\" />Да"
  #
  # @param choice [Array<[String, (Boolean|String|Symbol)]>]
  #
  # @return [String] stringified HTML for the input tag + its text
  #
  def input_tag_html(choice)

    # input_html_options => { id: "task_status", required: false, autofocus: false, readonly: false}
    #
    # input_html_options.merge(choice_html_options(choice)).merge({ required: false })
    # => { id: "task_status_completed", required: false, autofocus: false, readonly: false }
    #
    # builder                     => an instance of ActiveAdmin::FormBuilder
    # choice_label(choice)        => "Completed"
    # choice_html_options(choice) => { id: "task_status_completed" }
    # input_name                  => :status

    builder.radio_button(
      input_name,
      choice_value(choice),
      input_html_options.merge(choice_html_options(choice)).merge({ required: false, checked: selected?(choice) })
    ) << choice_label(choice)
  end


  # @!method label_html_options
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/radio_input.rb#L156 Original Formtastic method
  #
  #   Override to remove the `for=""` attribute, since this isn't associated with any element, as it's nested inside the legend
  #
  #   @return [Hash]
  #
  #   @example How it works under the hood
  #     { for: nil, class: ["label"] }


  # Options for a HTML tag builder
  #
  # @example
  #   label_tag_options(["Да", true])          #=> { for: "model_attribute_true", class: nil }
  #   label_tag_options(["Неизвестно", :null]) #=> { for: "model_attribute_null", class: nil }
  #
  # @param choice [Array<[String, (Boolean|String|Symbol)]>]
  #
  # @return [Hash]
  #
  def label_tag_options(choice)
    # choice_input_dom_id(choice) => "task_status_completed"
    # label_html_options          => { for: nil, class: ["label"] }
    label_html_options.merge({ for: choice_input_dom_id(choice), class: nil })
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
    options.fetch(:null, Formtastic::I18n.t(UNSET_KEY)).presence or fail StandardError.new(self.class.missing_i18n_error_msg)
  end


  # @!method legend_html
  #
  #   @note This method is not defined in this gem, and its documentation is given only because it is used in this class.
  #
  #   @example For `User#is_awesome`
  #     legend_html #=>
  #     "<legend class=\"label\">
  #       <label>Is awesome</label>
  #     </legend>"
  #
  #   @return [String] stringified HTML of the legend of the inputs group


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


  # @return [String] stringified HTML of fieldset with labels, radios & texts in it
  #
  # @example For `User#is_awesome`
  #   to_html #=>
  #   "<li class=\"tristate_radio input optional\" id=\"user_is_awesome_input\">
  #     <fieldset class=\"choices\">
  #       <legend class=\"label\">
  #         <label>Is awesome</label>
  #       </legend>
  #       <ol class=\"choices-group\">
  #       <li class=\"choice\">
  #         <label for=\"user_is_awesome_true\">
  #           <input id=\"user_is_awesome_true\" type=\"radio\" value=\"true\" name=\"user[is_awesome]\" />
  #           Да
  #         </label>
  #       </li>
  #       <li class=\"choice\">
  #         <label for=\"user_is_awesome_false\">
  #           <input id=\"user_is_awesome_false\" type=\"radio\" value=\"false\" name=\"user[is_awesome]\" />
  #           Нет
  #         </label>
  #       </li>
  #       <li class=\"choice\">
  #         <label for=\"user_is_awesome_null\">
  #           <input id=\"user_is_awesome_null\" type=\"radio\" value=\"null\" checked=\"checked\" name=\"user[is_awesome]\" />
  #           Неизвестно
  #         </label>
  #       </li>
  #       </ol>
  #     </fieldset>
  #   </li>"
  #
  def to_html
    # choice_wrapping_html_options(choice) #=> { class: "choice" }
    #
    # collection.map do |choice|
    #   choice_wrapping({ class: "choice" }) do
    #     choice_html(choice)
    #   end
    # end
    #
    # => ["<li class="choice">
    #        <label for="task_status_completed">
    #          <input type="radio" value="completed" name="task[status]" /> Completed
    #        </label>
    #      </li>",
    #     "<li class="choice">
    #      ...
    #    ]

    input_wrapping do
      choices_wrapping do
        legend_html <<  choices_group_wrapping do
                          collection.map { |choice|
                            choice_wrapping(choice_wrapping_html_options(choice)) {
                              choice_html(choice)
                            }
                          }.join("\n").html_safe
                        end
      end
    end
  end

end

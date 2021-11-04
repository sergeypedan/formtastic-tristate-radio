# frozen_string_literal: true

require "formtastic"

# It may also be appropriate to put this file in `app/inputs`
class TristateRadioInput < Formtastic::Inputs::RadioInput

  # @!attribute [r] template
  #   @return [Fixnum] the size of the list


  # No equals `:null`.
  #
  # Mind ActiveAdmin [status resolving logic](https://github.com/activeadmin/activeadmin/blob/master/lib/active_admin/views/components/status_tag.rb#L51):
  # in status tag builder the value is lowercased before casting into Boolean, and the keyword for nil is `"unset"`.
  # So if we have lowercase `"unset"`, translations from `ru.formtastic.unset` will be overriden by `ru.active_admin.status_tag.unset`.
  #
  UNSET_KEY = ActiveModel::Type::Boolean::NULL_VALUES.reject(&:blank?).first

  MISSING_TRANSLATION_ERROR_MSG = <<~HEREDOC
    For ActiveAdmin status tags in index & view tables:
    ru:
      active_admin:
        status_tag:
          :yes: Да
          :no: Нет
          :#{UNSET_KEY}: Неизвестно

    For radiobutton labels in forms:
    ru:
      formtastic:
        :yes: Да
        :no: Нет
        :#{UNSET_KEY}: Неизвестно

    Note: “yes”, “no”, “null” and some other words are reserved, converted into Boolean values in YAML, so you need to quote or symbolize them.
  HEREDOC


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
    # template #=> => #<ActionView::Base:0x00000000024c20> (an instance of ActionView::Base)
    template.content_tag(:label, input_tag_html(choice), tag_options(choice))
  end

  # @!method choice_value(choice)
  #
  #   @note This method is not defined in this gem, and its documentation is given only because, it is heavily used in this class.
  #
  #   @example
  #     choice_value(["Да", true]) #=> true
  #     choice_value(["Нет", false]) #=> false
  #     choice_value(["Неизвестно", :null]) #=> :null
  #
  #   @example What it does under the hood
  #     choice.is_a?(Array) ? choice[1] : choice
  #
  #   @param choice [Array<String, Boolean|String|Symbol>]
  #
  #   @return [Any] whichever value is the 2nd of the passed array
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/base/choices.rb#L55 Original Formtastic method


  # @example What this method brings about
  #   collection_with_unset #=> [["Да", true], ["Нет", false], ["Неизвестно", :null]]
  #
  # @return [Array<String, Boolean|String|Symbol>]
  #
  def collection_with_unset
    collection + [[unset_label_translation, UNSET_KEY]]
  end


  # @!method collection
  #
  #   @example
  #     collection #=> [["Да", true], ["Нет", false]]
  #
  #   @return [Array<String, Boolean|String|Symbol>]

  # @todo Remove `collection_with_unset` and just override `collection`
  #
  # def collection
  #   raw_collection.map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] } + [[unset_label_translation, UNSET_KEY]]
  # end


  # @!method label_html_options
  #
  #   @note This method is not defined in this gem, and its documentation is given only because, it is heavily used in this class.
  #
  #   @see https://github.com/formtastic/formtastic/blob/master/lib/formtastic/inputs/radio_input.rb#L156 Original Formtastic method
  #
  #   Override to remove the `for=""` attribute, since this isn't associated with any element, as it's nested inside the legend
  #
  #   @return [Hash]
  #
  #   @example How it works under the hood
  #     { for: nil, class: ["label"] }


  # @!method legend_html
  #
  #   @note This method is not defined in this gem, and its documentation is given only because, it is heavily used in this class.
  #
  #   @example
  #     legend_html #=>
  #     "<legend class=\"label\">
  #       <label>Human attribute name</label>
  #     </legend>"
  #
  #   @return [String] stringified HTML of the legend of the inputs group


  # @example For each result of `collection_with_unset` it runs:
  #   selected?(["Да", true]) #=> false
  #   selected?(["Нет", false]) #=> false
  #   selected?(["Неизвестно", :null]) #=> true
  #
  # @param choice [Array<String, Boolean|String|Symbol>]
  #
  # @return [Boolean] answer to the question “Is the passed option selected?”
  #
  # @note For this to work, `ActiveModel::Type::Boolean` must be patched to resolve `UNSET_KEY` as `nil`.
  #
  def selected?(choice)
    # method               => :status
    # object               => ActiveRecord::Base model subclass, `User`
    #
    ActiveModel::Type::Boolean.new.cast(choice_value(choice)) == object.public_send(method)
  end


  # @example
  #   input_tag_html(["Да", true])
  #   #=> "<input id=\"model_attribute_true\" type=\"radio\" value=\"true\" name=\"model[attribute]\" />Да"
  #
  # @param choice [Array<String, Boolean|String|Symbol>]
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


  # Options for a HTML tag builder
  #
  # @example
  #   tag_options(["Да", true])          #=> { for: "model_attribute_true", class: nil }
  #   tag_options(["Неизвестно", :null]) #=> { for: "model_attribute_null", class: nil }
  #
  # @param choice [Array<String, Boolean|String|Symbol>]
  #
  # @return [Hash]
  #
  def tag_options(choice)
    # choice_input_dom_id(choice) => "task_status_completed"
    # label_html_options          => { for: nil, class: ["label"] }
    label_html_options.merge({ for: choice_input_dom_id(choice), class: nil })
  end


  # @return [String] stringified HTML of fieldset with labels, radios & texts in it
  #
  # @example
  #   to_html #=>
  #   "<li class=\"tristate_radio input optional\" id=\"model_attribute_input\">
  #     <fieldset class=\"choices\">
  #       <legend class=\"label\">
  #         <label>Human attribute name</label>
  #       </legend>
  #       <ol class=\"choices-group\">
  #       <li class=\"choice\">
  #         <label for=\"model_attribute_true\">
  #           <input id=\"model_attribute_true\" type=\"radio\" value=\"true\" name=\"model[attribute]\" />
  #           Да
  #         </label>
  #       </li>
  #       <li class=\"choice\">
  #         <label for=\"model_attribute_false\">
  #           <input id=\"model_attribute_false\" type=\"radio\" value=\"false\" name=\"model[attribute]\" />
  #           Нет
  #         </label>
  #       </li>
  #       <li class=\"choice\">
  #         <label for=\"model_attribute_null\">
  #           <input id=\"model_attribute_null\" type=\"radio\" value=\"null\" checked=\"checked\" name=\"model[attribute]\" />
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
                          collection_with_unset.map { |choice|
                            choice_wrapping(choice_wrapping_html_options(choice)) {
                              choice_html(choice)
                            }
                          }.join("\n").html_safe
                        end
      end
    end
  end


  # @example
  #   unset_label_translation #=> "Неизвестно"
  #
  # @return [String] Label of the radio that stands for the unknown choice
  #
  # @raise [StandardError] if the translation could not be found
  # @see MISSING_TRANSLATION_ERROR_MSG
  #
  def unset_label_translation
    Formtastic::I18n.t(UNSET_KEY).presence or fail StandardError.new(MISSING_TRANSLATION_ERROR_MSG)
  end

end

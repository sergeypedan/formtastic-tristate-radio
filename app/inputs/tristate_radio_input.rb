# frozen_string_literal: true

require "formtastic"

# It may also be appropriate to put this file in `app/inputs`
class TristateRadioInput

  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Collections
  include Formtastic::Inputs::Base::Choices


  # UNSET_KEY = :null
  UNSET_KEY = ActiveModel::Type::Boolean::NULL_VALUES.reject(&:blank?).first
  #
  # Mind ActiveAdmin status resolving logic:
  # https://github.com/activeadmin/activeadmin/blob/master/lib/active_admin/views/components/status_tag.rb#L51
  # In status tag builder the value is lowercased before casting into boolean, and the keyword for nil is "unset", so
  # if we have lowercase "unset", translations from `ru.formtastic.unset` will be overriden by `ru.active_admin.status_tag.unset`.

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


  # template => an instance of ActionView::Base
  #
  # @param choice [Array], ["Completed", "completed"]
  #
  def choice_html(choice)
    template.content_tag(:label, tag_content(choice), tag_options(choice))
  end


  # collection => [["Completed", "completed"], ["In progress", "in_progress"], ["Unknown", "unset"]]
  #
  # @return [Array]
  #
  def collection_with_unset
    collection + [[unset_label_translation, UNSET_KEY]]
  end


  # Override to remove the for attribute since this isn't associated with any element, as it's nested inside the legend
  # @return [Hash]
  #
  # @example
  #   { for: nil, class: ["label"] }
  #
  def label_html_options
    super.merge({ for: nil })
  end


  # choice_value(choice) => true | false | UNSET_KEY <- in our version
  # choice_value(choice) => true | false | ?         <- in regular radio-buttons version
  # method               => :status
  # object               => ActiveRecord::Base model subclass, `User`
  #
  # @param choice [Array], ["Completed", "completed"]
  #
  # For this to work, ActiveModel::Type::Boolean must be patched to resolve `UNSET_KEY` as nil
  #
  def selected?(choice)
    ActiveModel::Type::Boolean.new.cast(choice_value(choice)) == object.public_send(method)
  end


  # @returns [String]
  #   "<input ...> Text..."
  #
  # @param choice [Array], ["Completed", "completed"]
  #
  # input_html_options => { id: "task_status", required: false, autofocus: false, readonly: false}
  #
  # input_html_options.merge(choice_html_options(choice)).merge({ required: false })
  # => { id: "task_status_completed", required: false, autofocus: false, readonly: false }
  #
  # builder                     => an instance of ActiveAdmin::FormBuilder
  # choice_label(choice)        => "Completed"
  # choice_html_options(choice) => { id: "task_status_completed" }
  # choice_value(choice)        => "completed"
  # input_name                  => :status
  #
  def tag_content(choice)
    builder.radio_button(
      input_name,
      choice_value(choice),
      input_html_options.merge(choice_html_options(choice)).merge({ required: false, checked: selected?(choice) })
    ) << choice_label(choice)
  end


  # choice_input_dom_id(choice) => "task_status_completed"
  # label_html_options          => { for: nil, class: ["label"] }
  #
  # @param choice [Array], ["Completed", "completed"]
  #
  def tag_options(choice)
    label_html_options.merge({ for: choice_input_dom_id(choice), class: nil })
  end


  # choice_wrapping_html_options(choice) #=> { class: "choice" }
  #
  # legend_html         => "<legend class="label">
  #                           <label>Status</label>
  #                         </legend>"
  #
  # choice_html(choice) => "<label for="task_status_completed">
  #                           <input type="radio" value="completed" name="task[status]" /> Completed
  #                         </label>"
  #
  # collection.map do |choice|
  #   choice_wrapping({ class: "choice" }) do
  #     choice_html(choice)
  #   end
  # end
  # => ["<li class="choice">
  #        <label for="task_status_completed">
  #          <input type="radio" value="completed" name="task[status]" /> Completed
  #        </label>
  #      </li>",
  #     "<li class="choice">
  #      ...
  #    ]
  #
  # This method relies on ActiveAdmin
  #
  def to_html
    choices = collection_with_unset #=> [["Completed", "completed"], ["In progress", "in_progress"], ["Unknown", "unset"]]

    input_wrapping do
      choices_wrapping do
        legend_html <<  choices_group_wrapping do
                          choices.map { |choice|
                            choice_wrapping(choice_wrapping_html_options(choice)) do
                              choice_html(choice)
                            end
                          }.join("\n").html_safe
                        end
      end
    end
  end


  # @return [String] Label of the radio that stands for the unknown choice
  #
  def unset_label_translation
    Formtastic::I18n.t(UNSET_KEY).presence or fail StandardError.new(MISSING_TRANSLATION_ERROR_MSG)
  end

end

# Formtastic tri-state radio

[![Gem Version](https://badge.fury.io/rb/formtastic_tristate_radio.svg)](https://badge.fury.io/rb/formtastic_tristate_radio)
[![Maintainability](https://api.codeclimate.com/v1/badges/c2508d7f23238fb2b87f/maintainability)](https://codeclimate.com/github/sergeypedan/formtastic-tristate-radio/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c2508d7f23238fb2b87f/test_coverage)](https://codeclimate.com/github/sergeypedan/formtastic-tristate-radio/test_coverage)

## What is “tri-state”?

— that which has 3 states.

By defenition Boolean values have 2 states: True & False.

However, if you store a Boolean value in a database column with no `NOT NULL` restriction, it aquires a 3<sup>d</sup> possible state: `null`.

Some may consider this practice questionable — I don’t think so. In real life you always have a case when the answer to your question may be only “yes” or “no”, but you don’t know the answer yet. Using a string type column, storing there `"yes"`, `"no"` and `"unset"` + using a state machine + validations — feels overkill to me.


## What the gem does

1. Provides a custom Formtastic input type `:tristate_radio` which renders 3 radios (“Yes”, “No”, “Unset”) instead of a checkbox (only where you put it).
1. Teaches Rails recognize `"null"` and `"nil"` param values as `nil`. See “[How it works](#how-it-works)” ☟ section for technical details on this.
1. Encourages you to add translations for ActiveAdmin “status tag” so that `nil` be correctly translated as “Unset” instead of “False”.


## Usage

For a Boolean column with 3 possible states:

```ruby
f.input :am_i_awake, as: :tristate_radio
```

You get (HTML is simplified, actually there are more classes etc.):

```html
<fieldset>
  <legend>Am i awake?</legend>
  <input name="am_i_awake" type="radio" value="true">  <label>Yes</label>
  <input name="am_i_awake" type="radio" value="false"> <label>No</label>
  <input name="am_i_awake" type="radio" value="null">  <label>Unset</label>
</fieldset>
```


## Installation

### Gem

```ruby
gem "formtastic_tristate_radio"
```

### Translations

Add translation for the new “unset” option:

```yaml
ru:
  formtastic:
    # :yes: Да       # <- these two fall back to translations
    # :no: Нет       #    in Formtastic gem but have only English
    null: Неизвестно # <- this you must provide youself
```

You can override individual translations like so:

```ruby
f.input :attribute, as: :tristate_radio, null: "Your text"
```

### ActiveAdmin translations

ActiveAdmin will automatically translate `nil` as “No”, so if you use ActiveAdmin, add translation like so:

```yaml
ru:
  active_admin:
    status_tag:
      :yes: Да
      :no: Нет
      unset: Неизвестно
```

Notice that the key ActiveAdmin uses is “unset”, not “null”.


## Configuration

It’s difficult to come up with a reasonable use case for that, but you can configure what will be used as inputs value:

```ruby
# config/initializers/formtastic.rb
FormtasticTristateRadio.configure do |config|
  config.unset_key = "__unset" # default is :null
end
```

which will result in:

```html
<input type="radio" name="am_i_awake" value="true">
<input type="radio" name="am_i_awake" value="false">
<input type="radio" name="am_i_awake" value="__unset">
```

Mind that for your custom value to work, you also need to configure `ActiveModel` to recognize that value as `nil`. Currently that is done [like so](https://github.com/sergeypedan/formtastic-tristate-radio/blob/master/config/initializers/activemodel_type_boolean.rb#L9).


## Documentation

Low-level methods are properly documented in RubyDoc [here](https://www.rubydoc.info/gems/formtastic_tristate_radio/TristateRadioInput).


## Dependencies

Now the gem depends on [Formtastic](https://github.com/formtastic/formtastic) (naturally) and Rails. Frankly I am not sure whether I will have time to make it work with other frameworks.


## How it works

In Ruby any String is cast to `true`:

```ruby
!!""      #=> true
!!"false" #=> true
!!"nil"   #=> true
!!"no"    #=> true
!!"null"  #=> true
```

Web form params are passed as plain text and are interpreted as String by Rack.

So how are Boolean values transfered as strings if a `"no"` or `"0"` and even `""` is truthy in Ruby?

Frameworks just have a list of string values to be recognized and mapped to Boolean values:

```ruby
ActiveModel::Type::Boolean::FALSE_VALUES
#=> [
   0, "0", :"0",
  "f", :f, "F", :F,
  false, "false", :false, "FALSE", :FALSE,
  "off", :off, "OFF", :OFF,
]
```

so that

```ruby
ActiveModel::Type::Boolean.new.cast("0")    #=> false
ActiveModel::Type::Boolean.new.cast("f")    #=> false
ActiveModel::Type::Boolean.new.cast(:FALSE) #=> false
ActiveModel::Type::Boolean.new.cast("off")  #=> false
# etc
```

So what [I do in this gem](https://github.com/sergeypedan/formtastic_tristate_radio/blob/master/config/initializers/activemodel_type_boolean.rb) is extend `ActiveModel::Type::Boolean` in a consistent way to teach it recognize null-ish values as `nil`:

```ruby
module ActiveModel
  module Type
    class Boolean < Value

      NULL_VALUES = [nil, "", "null", :null, "nil", :nil].to_set.freeze

      private def cast_value(value)
        NULL_VALUES.include?(value) ? nil : !FALSE_VALUES.include?(value)
      end

    end
  end
end
```

And voila!

```ruby
ActiveModel::Type::Boolean.new.cast("")     #=> nil
ActiveModel::Type::Boolean.new.cast("null") #=> nil
ActiveModel::Type::Boolean.new.cast(:null)  #=> nil
ActiveModel::Type::Boolean.new.cast("nil")  #=> nil
ActiveModel::Type::Boolean.new.cast(:nil)   #=> nil
```

**Warning**: as you might have noticed, default Rails behavior is changed. If you rely on Rails’ automatic conversion of strings with value `"null"` into `true`, this gem might not be for you (and you are definitely doing something weird).


## Roadmap

- [ ] Remove `require_relative "../app/models/active_record/base"` from main file
- [x] Make the gem configurable
- [x] Pull the key used for “unset” choice value into configuration
- [x] Add translations into most popular languages
- [ ] Load translations from gem
- [ ] Rgister `:tristate_radio` for Boolean columns with `null`
- [ ] Decouple `ActiveModel::Type::Boolean` thing from Formtastic things, maybe into a separate gem
- [ ] Decouple from Rails


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# frozen_string_literal: true

module FormtasticTristateRadio

  class << self
    attr_writer :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  # Configuration block pattern
  #
  # @see https://thoughtbot.com/blog/mygem-configure-block
  # @see https://brandonhilkert.com/blog/ruby-gem-configuration-patterns/
  #
  class Configuration

    def initialize
      @unset_key = :null
    end

    # @!attribute [r] unset_key
    #   @return [Symbol, String] the value of <var>@unset_key</var>
    #
    attr_reader :unset_key

    # @return [Symbol, String, Integer] value that was passed into the method
    #
    # @raise [TypeError] because no other types seem to make sence here
    #
    def unset_key=(value)
      fail TypeError, "`unset_key` must be a Symbol, String or Integer" unless [Symbol, String, Integer].include? value.class
      @unset_key = value
    end
  end

end

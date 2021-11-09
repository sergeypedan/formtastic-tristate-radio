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
    attr_accessor :unset_key

    def initialize
      @unset_key = :null
    end
  end

end

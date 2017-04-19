require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize (option={})
    otions.each do |property, value|
      self.send("#{property}=", value)
    end
  end

end

# Does not work: see environment.rb file for info
require_relative './config/environment'
require 'pry'

task :console do
  def reload!
    load_all './lib'
  end

  Pry.start
end

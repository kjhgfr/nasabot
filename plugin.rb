require 'set'

class Plugin
  @plugins = Set.new
  
  def initialize(bot)
    @bot = bot  
  end
  
  def self.plugins
    @plugins
  end
  
  def register_command(function, rights = USER::ALL, command = function)
    @bot.register_command(function, command, rights, self)
  end
  
  def self.inherited(subclass)
    @plugins << subclass
  end
end
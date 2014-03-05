require './irc'
require './config'
require './plugin'
require './constants'
require 'fileutils'

require 'sqlite3'

Dir["./plugins/*.plugin.rb"].each {|file| require file }

class Bot < IRC
  
  def initialize(channel)
    super(CONFIG::SERVER, CONFIG::PORT, CONFIG::USER, CONFIG::PASSWORD, channel)
    @commands = Hash.new
    @watchers = Hash.new
    @scheduled = Hash.new
    
    Plugin.plugins.each do |plugin|
      log "[ LOADING #{plugin} ]" if CONFIG::VERBOSE
      plugin_instance = plugin.new(self)      
      plugin_instance.register_functions
    end
    
  end
  
  def register_command(function, command, rights, plugin)
    @commands[command] = { function: function, users: rights, plugin: plugin}
    log "  [ FUNCTION: #{command} -> #{function}, USERGROUP: #{rights}]" if CONFIG::VERBOSE
  end
  
  def register_watcher(function, plugin)
    @watchers[function] = {function: function, plugin: plugin}
    log " [  WATCHER: #{function} ]" if CONFIG::VERBOSE
  end
  
  def handle_input(line)
    case line
      when /:(.+?)!.+PRIVMSG #.+ :\s*!(\S+)(.*)/i
        user = $1
        command = $2
        args = $3
        function_data = @commands[command]
        if !function_data.nil?
          function_data[:plugin].send(function_data[:function], user, args) if can_execute?(user, function_data)
        end
      else
        
    end
    
    @watchers.each do |function, watcher|
      watcher[:plugin].send(watcher[:function], line)
    end
  end
  
  
  def can_execute?(user, function_data)
    required = function_data[:users]
    case required
    when USER::ALL
      return true
    when USER::MODERATOR
      return user_mod?(user)
    when USER::BROADCASTER
      return user_broadcaster?(user)
    else 
      return false
    end
  end
  
  def start
    self.connect
    self.read_stream
  end
  
end
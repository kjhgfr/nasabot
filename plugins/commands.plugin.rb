class Commands < Plugin
  
  def initialize(bot)
    super(bot)
    @database = open_database('commands', {results_as_hash: false })
    @database.execute("CREATE TABLE IF NOT EXISTS 'commands' (cmd TEXT PRIMARY KEY, response TEXT);")
  end
  
  def add_command(user, args)
    if args.strip.empty?
      return help
    end
    
    command = args.split(" ")[0].gsub(/\s*/, '').downcase
    if command[0] == '!'
      command = command[1..-1]
    end
    
    output = args.split(" ")[1..-1].join(' ')
    
    return help if command.empty? || output.empty?
    return @bot.say("pls no spam, #{user}.") if command.length > 12
    begin
      @database.execute("INSERT INTO 'commands' VALUES (?, ?);", command, output)
      @bot.say "Added !#{command}."
    rescue SQLite3::ConstraintException
      @bot.say("!#{command} was not added.")
    end 
  end
  
  def help
    @bot.say "Usage: !add [COMMAND] [OUTPUT]. Example: !add bot nasabot best bot"
  end
  
  def delete_command(user, args)
    command = args.strip
    command = command[1..-1] if command[0] == '!'
    
    @database.execute("DELETE FROM 'commands' WHERE cmd=?;", command)
    count = @database.changes
    @bot.say("Deleted !#{command}.") if count > 0
  end
  
  def commands(user, args)
    result = @database.execute("SELECT cmd FROM 'commands';")
    commands = result.map {|cmd| cmd[0]}.map{|cmd| "!#{cmd}"}.join(' ')
    @bot.say "Commands: #{commands}. Use !add or !delete to add/delete commands."
  end
  
  def find_command(line)
    case line
     when /:(.+?)!.+PRIVMSG\s#.+\s:\s*!(\S+)/i
       command = $2
       user = $1
       @database.execute("SELECT response FROM commands WHERE cmd=? LIMIT 1;", command) do |result|
         @bot.say(result[0].gsub(/\[\[user\]\]/, user))
       end
     else
       
    end
  end
  
  def register_functions
    register_command('add_command', USER::MODERATOR, 'add')
    register_command('delete_command', USER::MODERATOR, 'delete')
    register_command('commands')
    register_watcher('find_command')
  end
end
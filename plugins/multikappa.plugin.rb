class Arrow < Plugin 
  
  def initialize(bot)
    super(bot)
    @database = open_database('arrow')
    @database.execute("CREATE TABLE IF NOT EXISTS 'multikappas' (user TEXT, kappas INTEGER);")
  end
  
  
  end
  
  def arrow(user, args) 
    arrowcount = arrow_count
    arrow = "Arrow " * arrowcount
    
    if arrowcount == 0
      @bot.say "#{user} missed the arrow!"
    else
      @bot.say "#{user} hit #{randomuser} with the arrow for #{duration} seconds!"
    end
  end


  
  def is_arrow?
    pls = 1 + rand(100)
    if pls <= arrowchance
      return true
    else
      return false
    end
  end

  def register_functions
    register_command('arrow')
  end 
end

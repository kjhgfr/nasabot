class Base < Plugin
  
  def mod(user, args)
    @bot.say("#{user} has a sword.")
  end
  
  def broadcaster(user, args)
    @bot.say("#{user} WOW UR A STREAMER Kreygasm")  
  end
  
  def quit(user, args)
    @bot.quit
  end
  
  def register_functions
    register_command('mod', USER::MODERATOR)
    register_command('broadcaster', USER::BROADCASTER, 'streamer')
    register_command('quit', USER::BROADCASTER)
  end
end
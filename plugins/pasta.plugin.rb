class Pasta < Plugin
  def hitler(user, args)
    @bot.say "http://i.imgur.com/41NADLV.jpg"
  end
  
  def fuckchat(user, args)
    @bot.say "http://i.imgur.com/PvN8Rqd.gif"
  end
  
  def littlesister(user, args)
    @bot.say "https://www.youtube.com/watch?v=cOenzaclYbk"
  end
  
  def register_functions
    register_command('hitler')
    register_command('fuckchat')
    register_command('littlesister')
  end
end
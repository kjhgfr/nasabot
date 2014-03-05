class Imgur < Plugin
   
  def initialize(bot)
    super(bot)
    @database = open_database('imgur')
    @database.execute("CREATE TABLE IF NOT EXISTS 'images' (code TEXT PRIMARY KEY, url TEXT, added_by TEXT);")
  end
  
  def parse_images(line)
    case line
     when /:(.+?)!.+PRIVMSG\s#.+\s:.*((?:https?:\/\/)?(?:i.)?imgur.com\/((?:(?:gallery|a)\/)?\S*)(?:\.[a-z]{3})?)/i
       url = $2
       code = $3
       user = $1
       add_image(code, url, user)       
     end
  end
  
  def add_image(code, url, user)
    begin
      @database.execute("INSERT INTO 'images' VALUES (?, ?, ?);", code, url, user)
      puts "added image: #{url}" if CONFIG::DEBUG && @database.changes > 0
    rescue SQLite3::ConstraintException
      puts "#{url} was not added" if CONFIG::DEBUG
    end
    
  end
  
  def random_image(user, args)
    image = @database.execute("SELECT url FROM 'images' ORDER BY RANDOM() LIMIT 1;")
    return if image.nil?
    @bot.say(image.first["url"])
  end
  
  def register_functions
    register_watcher('parse_images')
    register_command('random_image', USER::ALL, 'randomimage')
  end
end
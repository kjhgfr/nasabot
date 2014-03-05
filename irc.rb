require 'socket'
require 'set'
require 'time'

class IRC 
  def initialize(server, port, nick, password, channel)
    @logfile = File.open(CONFIG::LOGFILE % channel, "a+")
    @server = server
    @port = port
    @nick = nick
    @password = password
    @channel = channel
    @users = Set.new
    @moderators = Set.new
    @moderators << 'subecx' 
    @message_queue = Array.new
    @running = false
  end
  
  def connect
    @running = true
    @socket = TCPSocket.open(@server, @port)
    send "PASS #{@password}", true
    send "NICK #{@nick}"
    send "JOIN #{@channel}"
  end
  
  def quit
    send "QUIT"
    @socket.close
  end
  
  def send(message, mute = false)
    @socket.send "#{message}\n", 0
    log "  [ SENDING: #{message} ]" if CONFIG::VERBOSE && !mute
  end
  
  def queue
    length = 0
    send = @message_queue.select {|value| (length = length + value.length) &&  length <= CONFIG::MESSAGEMAXLENGTH}
    send.each { |value| 
      @message_queue.delete_at(@message_queue.index(value))
      
    }
    return send.join(CONFIG::MESSAGEDELIMITER)
  end
  
  def say(message)
    if message[CONFIG::MESSAGEMAXLENGTH-1].nil?
      @message_queue << message
    else
      last_space = message[0..CONFIG::MESSAGEMAXLENGTH-1].rindex(/\s/)
      @message_queue << message[0..last_space]
      say(message[last_space+1..-1])
    end
    
  end
  
  def send_message_queue   
    message = queue
    return if message.empty?
    
    send "PRIVMSG #{@channel} :#{message}"
  end
  
  def read_stream
    Signal.trap("HUP") { @running = false }
    messages = Thread.new {
      while @running
        sleep(CONFIG::MESSAGEDELAY)
        send_message_queue       
      end
    }
    begin
      while (line = @socket.readline) && @running
        irc_handle line
      end
    rescue => error
      log error
    end
    quit
    exit
    
  end
  
  def irc_handle line   
    log line if CONFIG::DEBUG
    
    case line.strip
      when /^PING :?(.+)$/i
        log "[ SERVER PING ]"
        send "PONG :#{$1}"
        
      when /^:jtv MODE #.+ (\+|-)o (.+)$/i
        handle_mod($2, $1)
        
      when /:\w*\.?\w*\.\w* \d{3} .+ :-?\s?(.+?)\s?-?$/i
        
      when /^:.+353.*=\s#.+\s:(.+)/i
        handle_userlist($1)
        
      when /^:(.+)!.+(JOIN|PART)\s#.+/i
        handle_user($1, $2)
        
      else
        handle_input line       
    end
  end
  
  def user_mod?(user)
    @moderators.include?(user)
  end
  
  def user_broadcaster?(user)
    user == @channel[1..-1]
  end
    
  def handle_user(user, type)
    if type == "JOIN"
       @users << user
     elsif type == "PART"
       @users.delete(user)
    end    
  end
  
  def handle_mod(user, type)
    if type == '+'
      @moderators << user
    elsif type == '-'
      @moderators.delete(user)
    end    
  end
  
  def handle_userlist(userlist)
    users = userlist.split(" ")
    users.each do |user|
      @users << user.strip
    end   
  end
  
  def log(message)
    @logfile.write("#{message}\n")
    @logfile.flush
  end
  
  def moderators
    @moderators
  end
  
  def users
    @users
  end
  
  def channel
    return @channel
  end
end
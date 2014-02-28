require 'socket'
require 'set'

class IRC 
  def initialize(server, port, nick, password, channel)
    @server = server
    @port = port
    @nick = nick
    @password = password
    @channel = channel
    @users = Set.new
    @moderators = Set.new  
  end
  
  def connect
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
    puts "  [ SENDING: #{message} ]" if CONFIG::VERBOSE && !mute
  end
  
  def say(message)
    send "PRIVMSG #{@channel} :#{message}"
  end
  
  def read_stream
    while line = @socket.readline
      irc_handle line
    end
  end
  
  def irc_handle line   
    puts line if CONFIG::DEBUG
    
    case line.strip
      when /^PING :?(.+)$/i
        puts "[ SERVER PING ]"
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
  
  def moderators
    @moderators
  end
  
  def users
    @users
  end
end
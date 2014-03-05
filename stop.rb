require 'yaml'

channels = ARGV.map{|chan| "##{chan}"}

pids = YAML.load_file('./PIDS')

channels.each do |channel|
  if !pids.has_key?(channel)
    puts "There is no bot running in #{channel}"
    next
  end
  
  Process.kill("HUP", pids[channel])
  pids.delete(channel)
  puts "Bot stopped for #{channel}"
end

puts pids.inspect

File.open('./PIDS', 'w') { |f| f.puts pids.to_yaml }
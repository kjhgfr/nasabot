require 'sqlite3'
require 'optparse'
require 'json'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ./migrate [options]"
  
  opts.on("-s", "--source DATABASE", "Path to source database") do |database|
    options[:source_database] = database
  end
  
  opts.on("-t", "--target DATABASE", "Path to target database") do |database|
    options[:target_database] = database
  end
  
  options[:mute] = false
  opts.on("-m", "--mute", "Dont output anything") do
    options[:mute] = true
  end
end

optparse.parse!

#source_tables = options[:source_database].tables

puts "SOURCE: #{options[:source_database]} TARGET: #{options[:target_database]}" unless options[:mute]

#LOADING DATABASES
source_database = SQLite3::Database.new(options[:source_database], { results_as_hash: true })
target_database = SQLite3::Database.new(options[:target_database], { results_as_hash: true })

#GET SOURCE TABLES

source_tables = source_database.execute("SELECT name FROM sqlite_master WHERE type='table';")
source_tables.each do |table|
  query = "SELECT * FROM #{table["name"]};"

  source_data = source_database.execute(query)
  
  source_data.each do |row|
    data = row.select {|k,v| k.is_a?(String)}
    query = "INSERT INTO #{table["name"]} VALUES (#{data.keys.map {|key| ':'+key}.join(',')});"
    
    begin
      stmt = target_database.prepare(query)
      stmt.bind_params(data)
      stmt.execute
      puts "#{data.first} added." unless options[:mute]
    rescue SQLite3::ConstraintException
      puts "#{data} was not added." unless options[:mute]
    end
    
    
  end
end

require 'rubygems'

# Adapts the Sequel object representing a sqlite3-jdbc connection to the
# contract expected by our app, which is SQLite3::Database.
# Only implements a minimum of methods - the ones I've used in my other code.
class JrubySqliteAdapter
  def initialize(filename)
    require 'sequel'
    @jdbc = Sequel.connect("jdbc:sqlite:#{filename}")
  end

  def execute(sql, *args)
    #puts "JrubySqliteAdapter: sql = '#{sql}', args = #{args.inspect}"
    @jdbc.fetch(sql, *args) do |row|
      row_idx = 0

      # make rows indexable by number as well as key
      row.keys.each do |key|
        row[row_idx] = row[key]
        row_idx += 1
      end

      yield row
    end
  end
  
  def close
    #puts "JrubySqliteAdapter: close: jdbc.methods = #{@jdbc.methods.sort.inspect}"
    @jdbc.disconnect
    @jdbc = nil
  end
end

module SqliteHelper
  def self.connect(filename)
    res_db = nil
    
    if (RUBY_PLATFORM =~ /java/)
      res_db = JrubySqliteAdapter.new(filename)
    else
      gem 'sqlite3-ruby'
      require 'sqlite3'

      res_db = SQLite3::Database.new(filename)
    end
    
    res_db
  end
end

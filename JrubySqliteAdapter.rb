require 'rubygems'
require 'sequel'

class JrubySqliteAdapter
  def initialize(filename)
    @jdbc = Sequel.connect("jdbc:sqlite:#{filename}")
  end
  
  def execute(sql, *args)
    @jdbc.fetch(sql, args) do |row|
      row_idx = 0

      # make rows indexable by number as well as key
      row.keys.each do |key|
        row[row_idx] = row[key]
        row_idx += 1
      end
      
      yield row
    end
  end
end

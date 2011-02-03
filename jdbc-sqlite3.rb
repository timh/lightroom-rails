# JRUBY only

require 'rubygems'
require 'sequel'

def p_methods(str, o)
  puts ""
  puts "methods for #{str} ::"
  o.methods.sort.each do |m|
    puts "  #{m}"
  end
end

db = Sequel.connect('jdbc:sqlite:Lightroom 3 Catalog-2.lrcat')
puts "DB is #{db}"
#p_methods("db", db)

db.fetch("select id_local, name from AgLibraryRootFolder") do |row|
  puts "one row is id_local = #{row[:id_local]}, name = #{row[:name]}"
  puts "row.keys is #{row.keys.join ', '}"
end

#r = db.select("select id_local, name from AgLibraryRootFolder")
#puts "r is #{r}"
#p_methods("r", r)

  



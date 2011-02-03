
def foo(sql, *args)
  puts "sql: '#{sql}'"
  puts "args: '#{args}'"
  puts "args.inspect: '#{args.inspect}'"
  
  arr = [1,2]
  puts "[1,2].inspect: '#{arr.inspect}'"
end

foo('sql', 1, 2)

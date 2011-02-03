#!/usr/bin/ruby -w

require 'PreviewParser'

preview_filename = ARGV[0] || "previews/karl_campfire--00_after-import.nef.preview"
p = PreviewParser.new(preview_filename)

html = File.open("rawdata/index.html", "w")
html.puts("<table><tr>")

idx = 1
p.previews.each do |preview|
  puts "preview is #{preview}"
end

html.puts("</tr></table>")
html.close


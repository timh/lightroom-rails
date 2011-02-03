#!/usr/bin/ruby -w

require 'rubygems'

require 'RootFolder'
require 'Folder'
require 'Picture'
require 'PreviewParser'

##########################################

directory_name = ARGV[0] || 'local_from_mac/2008-08-03.d300.camping-3/'
if (directory_name !~ /\/$/)
  directory_name = "#{directory_name}/"
end
puts "directory_name = #{directory_name}"

# Open the SQLITE database.
lightroom_catalog_filename = "Lightroom 3 Catalog-2.lrcat"
db = nil

puts "RUBY_PLATFORM is #{RUBY_PLATFORM}"
if (RUBY_PLATFORM =~ /java/)
  require 'JrubySqliteAdapter'

  db = JrubySqliteAdapter.new(lightroom_catalog_filename)
else
  gem 'sqlite3-ruby'
  require 'sqlite3'
  db = SQLite3::Database.new(lightroom_catalog_filename)
end

rootFoldersById = {}
rootFoldersByPath = {}

##########
# read in root folders.
db.execute("select id_local, name from AgLibraryRootFolder") do |row|
  
  id, name = row[0], row[1]
  puts "ROOT FOLDER: id #{id}, name #{name}"
  
  newRootFolder = RootFolder.new(id, name)
  rootFoldersById[id] = newRootFolder
  rootFoldersByPath[name] = newRootFolder
end


##########
# get all folders that are part of a particular root folder.
rootFolderName = directory_name.split('/')[0]
rootFolder = rootFoldersByPath[rootFolderName]

puts "-- rootFolderName #{rootFolderName}, rootFolder #{rootFolder}"

folders = []
foldersByPath = {}
db.execute("select id_local, pathFromRoot from AgLibraryFolder where rootFolder = ?", rootFolder.id) do |row|
  id, pathFromRoot = row[0], row[1]
  #puts "FOLDER: id #{id}, pathFromRoot #{pathFromRoot}"
  
  newFolder = Folder.new(id, rootFolder, pathFromRoot)
  folders.push(newFolder)
  foldersByPath[newFolder.path] = newFolder
end


# get all images in a given folder.
pictures = []
picturesById = {}
folder = foldersByPath[directory_name]
#folder = folders[0]

puts "found the folder: #{folder}"
# inner join on adobe_images to get the guid for the preview.
db.execute(
"""SELECT file.id_local, file.idx_filename, pyramid.relativeDataPath FROM AgLibraryFile file 
INNER JOIN Adobe_images image ON image.rootFile = file.id_local 
INNER JOIN Adobe_previewCachePyramids pyramid ON pyramid.id_local = image.pyramidIDCache 
WHERE folder = ?""", folder.id) do |row|
  id, idxFilename, previewPath = row[0], row[1], row[2]
  puts "PICTURE: id #{id}, idxFilename #{idxFilename}, previewPath #{previewPath}"
  
  newPicture = Picture.new(id, idxFilename, folder)
  newPicture.previewPath = previewPath
  pictures.push(newPicture)
  picturesById[id] = newPicture
end

html = File.open("html/index.html", "w")
html.puts("<table><tr>")
num_pics = 0

pictures.each do |pic|
  puts
  puts "PIC: #{pic} preview:"
  cwd_preview_filename = "previews/#{pic.filename}.preview"
  if (File.exists?(cwd_preview_filename) || File.symlink?(cwd_preview_filename))
    puts "  remove #{cwd_preview_filename}"
    File.delete(cwd_preview_filename)
  end
  if (pic.previewPath == nil)
    puts "  #{pic} has no preview"
    next
  end
  
  lr_preview_filename = "../Lightroom 3 Catalog Previews-2.lrdata/#{pic.previewPath}"
  
  puts "  ln -sf '#{lr_preview_filename}' '#{cwd_preview_filename}'"
  File.symlink(lr_preview_filename, cwd_preview_filename)

  print "  "; system("ls -la '#{cwd_preview_filename}'")
  print "  "; system("ls -laL '#{cwd_preview_filename}'")

# parse the previews..  
  parser = PreviewParser.new(cwd_preview_filename)
  preview = parser.find_preview(300)
  if (preview == nil)
    preview = parser.previews[-1]
  end
  
  preview_filename = "#{pic.filename}.#{preview.width}X#{preview.height}.jpg"

  preview.write_preview("html/#{preview_filename}")
  
  html.puts "  <td><img src=\"#{preview_filename}\"><br/>#{preview_filename}</td>"
  num_pics += 1
  if (num_pics % 4 == 0)
    html.puts "</tr>"
    html.puts "<tr>"
  end
end
html.puts "</tr>"
html.puts "</table>"
html.close



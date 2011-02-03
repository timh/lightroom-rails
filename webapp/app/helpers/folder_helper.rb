require 'RootFolder'

module FolderHelper
  def self.find_by_directory(directory_name, want_pics = nil)
    res_folder = nil
    
    # append a / if it's not already there.
    if (directory_name !~ /\/$/)
      directory_name = "#{directory_name}/"
    end
    
    # extract the first and the rest of the folders
    root_folder_name = directory_name.split('/')[0]
    folder_name = (directory_name.split('/')[1..-1]).to_s + "/"
    
    puts "find_by_directory: start: directory_name #{directory_name}  ::  root_folder_name #{root_folder_name}, folder_name #{folder_name}"

    # look up the folder and the root folder at the same time.
    lightroom_db = ApplicationHelper.lightroom_database
    preview_db = ApplicationHelper.preview_database
    lightroom_db.execute("SELECT folder.id_local, folder.pathFromRoot, root_folder.id_local as root_folder_id FROM AgLibraryFolder folder INNER JOIN AgLibraryRootFolder root_folder ON root_folder.id_local = folder.rootFolder WHERE root_folder.name = ? AND folder.pathFromRoot = ?", root_folder_name, folder_name) do |row|
      local_id, path_from_root, root_folder_id = row[0], row[1], row[2]

      root_folder = RootFolder.new(root_folder_id, root_folder_name)
      res_folder = Folder.new(local_id, root_folder, path_from_root)
    end
    
    # load the picture contents in if asked for
    if (want_pics)
      puts "have a res_folder.local_id = #{res_folder.local_id}"

      res = PictureHelper.find_pictures_in_folder(res_folder)
    end
    
    puts "find_by_directory: res is #{res_folder.inspect}"
    res_folder
  end

end

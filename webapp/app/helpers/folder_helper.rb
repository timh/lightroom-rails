require 'RootFolder'

module FolderHelper
  # Will return Folder or RootFolder
  def self.find_by_directory(directory_name, want_pics = nil)
    res_folder = nil
    want_root_of_roots = false
    
    # append a / if it's not already there.
    if (directory_name !~ /\/$/)
      directory_name = "#{directory_name}/"
    end
    
    # extract the first and the rest of the folders
    root_folder_name = directory_name.split('/')[0]
    rest = directory_name.split('/')[1..-1].to_s
    if rest.length == 0
      folder_name = ""
    elsif root_folder_name.length == 0
      want_root_of_roots = true
    else
      folder_name = rest + "/"
    end
    
    lightroom_db = ApplicationHelper.lightroom_database
    preview_db = ApplicationHelper.preview_database

    puts "find_by_directory: START: directory_name #{directory_name} :: root_folder_name #{root_folder_name}, folder_name #{folder_name}"
    puts "                        : want_root_of_roots #{want_root_of_roots}"

    # Handle the case where a blank path was passed in -- the root of roots.
    if want_root_of_roots
      root_folder = RootFolder.new(0, "")
      lightroom_db.execute("SELECT id_local, name FROM AgLibraryRootFolder") do |rootfolder_row|
        new_root_folder = RootFolder.new(rootfolder_row[0], rootfolder_row[1] + "/")
        root_folder.child_folders << new_root_folder
      end

      return root_folder
    end

    # Pull out the root folder.
    rootfolder_rows = lightroom_db.execute("SELECT root_folder.id_local FROM AgLibraryRootFolder root_folder WHERE root_folder.name = ?", root_folder_name)
    return nil unless rootfolder_rows && rootfolder_rows.length > 0
    rootfolder_row = rootfolder_rows.first
    root_folder = RootFolder.new(rootfolder_row[0], root_folder_name + "/")

    # now pull out the folder.
    folder_rows = lightroom_db.execute("SELECT folder.id_local, folder.pathFromRoot FROM AgLibraryFolder AS folder WHERE folder.rootFolder = ? AND folder.pathFromRoot = ?", root_folder.local_id, folder_name)
    return nil unless folder_rows && folder_rows.length > 0
    folder_row = folder_rows.first
    res_folder = Folder.new(folder_row[0], folder_row[1], root_folder)

    # load up child folders.
    # if res_folder is the folder that represents the same path as the 
    # root_folder, we're setting this length to zero, as when we're searching
    # for subdirectories we don't care about this path 
    child_folder_prefix = "#{res_folder.path_from_root}%"
    child_folder_prefix_length = res_folder.path_from_root.length

    puts "LOOKHERE: child prefix is #{child_folder_prefix}"
    lightroom_db.execute("SELECT folder.id_local, folder.pathFromRoot FROM AgLibraryFolder folder WHERE folder.rootFolder = ? AND folder.pathFromRoot LIKE ? AND folder.id_local != ?", root_folder.local_id, child_folder_prefix, res_folder.local_id) do |child_row|
      local_id, path_from_root = child_row[0], child_row[1]

      # Skip to next if this is a grandchild or further down.. It should have 
      # only one more slash in its path beyond the folder it's in.
      next if path_from_root[child_folder_prefix_length..-1].count("/") > 1
      puts "LOOKHERE: got a hit.. path_from_root = #{path_from_root}; id_local #{local_id}; shouldn't match #{res_folder.local_id}"

      child_folder = Folder.new(local_id, path_from_root, res_folder)
      res_folder.child_folders << child_folder
    end

    # load the picture contents in if asked for
    if (want_pics)
      res = PictureHelper.find_pictures_in_folder(res_folder)
    end
    
    puts "find_by_directory: res is #{res_folder.inspect}"
    res_folder
  end

end

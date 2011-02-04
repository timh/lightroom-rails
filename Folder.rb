class Folder
  attr_accessor :local_id
  attr_accessor :parent_folder
  attr_accessor :path_from_root
  
  attr_accessor :pictures
  attr_accessor :child_folders
  
  # parentFolder = Folder OR RootFolder
  def initialize(local_id, path_from_root, parent_folder)
    @local_id = local_id
    @parent_folder = parent_folder
    @path_from_root = path_from_root
    @pictures = Array.new
    @child_folders = Array.new
  end
  
  def path
    # The path passed in is expected to have
    "#{parent_folder.path}#{path_from_root}"
  end
  
  def to_s
    "Folder #{path} (#{local_id})"
  end
end


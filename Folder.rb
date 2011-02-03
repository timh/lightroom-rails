class Folder
  attr_accessor :local_id
  attr_accessor :rootFolder
  attr_accessor :pathFromRoot
  
  attr_accessor :pictures
  
  def initialize(local_id, rootFolder, pathFromRoot)
    @local_id = local_id
    @rootFolder = rootFolder
    @pathFromRoot = pathFromRoot
    @pictures = []
  end
  
  def path
    "#{rootFolder.path}/#{pathFromRoot}"
  end
  
  def to_s
    "Fold #{path} (#{local_id})"
  end
end


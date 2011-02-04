class RootFolder
  attr_accessor :local_id
  attr_accessor :path
  attr_accessor :child_folders
  
  def initialize(local_id, path)
    @local_id = local_id
    @path = path
    @child_folders = Array.new
  end

  def to_s
  	"Root #{path}"
  end

  def pictures
  	[]
  end
end


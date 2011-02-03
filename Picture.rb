class Picture
  attr_accessor :local_id
  attr_accessor :global_id
  attr_accessor :filename
  attr_accessor :folder
  
  attr_accessor :previewPath

  def initialize(local_id, global_id, filename, folder)
    @local_id = local_id
    @global_id = global_id
    @filename = filename
    @folder = folder
  end
  
  def to_s
    if (folder != nil)
      "Pic #{folder.path}#{filename} (#{local_id})"
    else
      "Pic ??/#{filename} (#{local_id})"
    end
  end
end


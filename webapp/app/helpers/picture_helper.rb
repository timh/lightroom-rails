# Ugh this is kinda weak..

module PictureHelper
  def self.find_picture_by_local_id(local_id)
    res = find_pictures_by_id(local_id, nil, nil)

    res.length > 0 ? res.first : nil
  end

  def self.find_picture_by_global_id(global_id)
    res = find_pictures_by_id(nil, global_id, nil)

    res.length > 0 ? res.first : nil
  end
  
  def self.find_pictures_in_folder(folder)
    res = find_pictures_by_id(nil, nil, folder.local_id)
    res.each do |new_pic|
      folder.pictures << new_pic
      new_pic.folder = folder
    end
    res
  end
  
  def self.find_pictures_by_id(local_id, global_id, folder_id)
    res = Array.new
    
    puts "Picture.find_pictures_by_id: local_id = #{local_id}, global_id = #{global_id}, folder_id = #{folder_id}"

    db_query = if local_id
                 ["""SELECT file.id_local, file.id_global, file.idx_filename FROM AgLibraryFile file 
                  WHERE file.id_local = ?""", local_id]
               elsif global_id
                 ["""SELECT file.id_local, file.id_global, file.idx_filename FROM AgLibraryFile file 
                  WHERE file.id_global = ?""", global_id]
               elsif folder_id
                 res_array = Array.new

                 ["""SELECT file.id_local, file.id_global, file.idx_filename FROM AgLibraryFile file 
                  WHERE file.folder = ?""", folder_id]
               else
                 raise "must specify local_id (file), global_id (file), or folder_id (folder)"
               end
    puts "PICTURE: db_query = #{db_query.inspect}"

    # look up the image.
    ApplicationHelper.lightroom_database.execute(*db_query) do |file_row|
      local_id, global_id, idx_filename= file_row[0], file_row[1], file_row[2]
      puts "PICTURE: local_id #{id}, global_id #{global_id}, idx_filename #{idx_filename}"

      ApplicationHelper.preview_database.execute(
        """SELECT uuid,digest FROM Pyramid WHERE uuid = ?""", global_id) do |pyramid_row|
        _unused_global_id, digest = pyramid_row[0], pyramid_row[1]

        first_digit = global_id[0..0]
        first_four_digits = global_id[0..3]
        preview_path = "lightroom-previews.lrdata/#{first_digit}/#{first_four_digits}/#{global_id}-#{digest}.lrprev"

        puts "NEW PICTURE: id_local #{local_id}, id_global #{global_id} idx_filename #{idx_filename}"
        puts "           : digest #{digest}"
        puts "           : preview_path #{preview_path}"

        new_pic = Picture.new(local_id, global_id, idx_filename, nil)
        new_pic.previewPath = preview_path

        res << new_pic
      end
    end
    
    puts "Picture.find_pictures_by_id: res is #{res.inspect}"
    res
  end
  
end

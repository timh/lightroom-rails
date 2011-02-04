class FolderController < ApplicationController
  def show
  	# Look up the folder..
    @folder = FolderHelper.find_by_directory(params[:path], 1)

    raise "can't find folder with path #{params[:path]}" unless @folder

    puts "LOOKHERE: folder.path is #{@folder.path}"
    if @folder.path =~ /^(.+\/)([^\/]+)\/$/
      @parent_folder_path = $1
	else
	  @parent_folder_path = ""
    end

    puts "parent_folder_path = #{@parent_folder_path}"
    
    # rest handled in the html generation.
    #if (RUBY_PLATFORM =~ /java/)
    #else
      #ApplicationHelper.close_database
    #end
  end

end

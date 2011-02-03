class FolderController < ApplicationController
  def show
    @folder = FolderHelper.find_by_directory(params[:path], 1)
    
    # rest handled in the html generation.
    #if (RUBY_PLATFORM =~ /java/)
    #else
      #ApplicationHelper.close_database
    #end
  end

end

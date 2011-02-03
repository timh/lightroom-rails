
require 'RootFolder'
require 'Folder'
require 'PreviewParser'

class PictureController < ApplicationController
  def image
    # I cannot figure out how to get this to work "right", with respond_to, and format
    id = params[:id]

    # look up the picture by its id
    pic = PictureHelper.find_by_id(id)

    # TODO: need error handling here (what happens if the pic couldn't be found?)
    if (pic != nil)
      preview_parser = PreviewParser.new(pic)

      preview = preview_parser.find_preview(100)

      send_data preview.preview_data, :type => "image/jpeg", :disposition => "inline"
    end

    #if (RUBY_PLATFORM =~ /java/)
    #else
      #ApplicationHelper.close_database
    #end
  end
end

require 'SqliteHelper'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def self.initialize
    puts "ApplicationHelper.self.initialize"
    @lightroom_db = nil
    @preview_db = nil
  end
  
  def self.lightroom_database
    puts "ApplicationHelper.self.lightroom_database: called on self = #{self.inspect}"
    
    if (@lightroom_db == nil)
      puts "  @lightroom_db not defined."
      lightroom_catalog_filename = "lightroom-catalog.lrcat"

      @db = SqliteHelper.connect(lightroom_catalog_filename)
    else
      puts "  @lightroom_db was defined and saved"
    end

    puts "ApplicationHelper.lightroom_database: @lightroom_db = #{@db}"

    @db
  end
  
  def self.preview_database
    puts "ApplicationHelper.self.preview_database: called on self = #{self.inspect}"
    
    if (@preview_db == nil)
      puts "  @preview_db not defined."
      preview_catalog_filename = "lightroom-previews.lrdata/previews.db"

      @db = SqliteHelper.connect(preview_catalog_filename)
    else
      puts "  @preview_db was defined and saved"
    end

    puts "ApplicationHelper.preview_database: @preview_db = #{@db}"

    @db
  end
  
  def self.close_databases
    puts "ApplicationHelper.self.close_databases: called on self = #{self.inspect}"
    if (@lightroom_db != nil)
      @lightroom_db.close
      @lightroom_db = nil
    end

    if (@preview_db != nil)
      @preview_db.close
      @preview_db = nil
    end
  end
  
end

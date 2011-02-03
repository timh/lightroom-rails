#!/usr/bin/ruby -w

# This is assuming everything's in network byte order (big endian)
class PreviewParser
  class Preview
    attr_accessor :offset, :length, :width, :height
    
    def initialize(offset, length, width, height, buf)
      @offset = offset
      @length = length
      @width = width
      @height = height
      @buf = buf
    end
    
    def preview_data
      @buf
    end
    
    def write_preview(stream_or_filename)
      if (stream_or_filename.kind_of? File)
        stream_or_filename.write(@buf)
      else
        File.open(stream_or_filename, "w") do |file|
          file.write(@buf)
        end
      end
    end

    def to_s
      "preview #{width} X #{height}"
    end
  end

  attr_accessor :previews
  
  def initialize(filename)
    if (filename.kind_of? Picture)
      filename = "lightroom-previews.lrdata/#{filename.previewPath}"
    end
    
    @filename = filename
    @widths = Array.new
    @heights = Array.new
    
    @previews = Array.new
    
    @mem_buf = IO.read(filename)
    parse
    @mem_buf = nil
  end
  
  def int_at(pos)
    # Unpack in NETWORK byte order. Is this right?
    @mem_buf[pos .. pos+4].unpack("N*")[0]
  end

  def short_at(pos)
    # Network byte order. Is this right?
    @mem_buf[pos .. pos+1].unpack("n*")[0]
  end  

  def parse_at_offset(idx, pos)
    cookie = @mem_buf[pos .. pos + 3]
    if (cookie != 'AgHg')
      puts "cookie isn't AgHg, it's '#{cookie}'"
    end
    
    # puts "cookie = #{cookie}"
    
    # should be 
    # 0x00200000 for header
    # 0x00200010 for picture
    type_code = int_at(pos + 4)
    type_code_hex = sprintf("0x%x", type_code)
    
    length_of_data = int_at(pos + 12)
    length_of_padding = int_at(pos + 20)
    
    # puts "AT POSITION #{pos}:"
    # puts "  type code = #{type_code}, #{type_code_hex}"
    # puts "  length_of_data = #{length_of_data}"
    # puts "  length_of_padding = #{length_of_padding}"
    if (type_code == 0x200000)
      # puts "  .. header"

      curly_indentation = 0
      in_levels_construct = 0
      header_idx = 1
      
      header = @mem_buf[pos + 32 .. pos + 32 + length_of_data - 1]
      # puts "header:\n#{header}"
      
      header.each do |line|
        if (line =~ /levels = \{/)
          in_levels_construct = 1
        elsif (in_levels_construct)
          if (line =~ /^\s*\{\s*$/)
            curly_indentation += 1
          elsif (line =~ /^\s*\}(,?)\s*$/)
            curly_indentation -= 1
            if (curly_indentation < 0)
              in_levels_construct = 0
            elsif (curly_indentation == 0)
              header_idx += 1
            end
          elsif (m = (line.match(/width = (\d+),/)))
            @widths[header_idx] = m[1].to_i
          elsif (m = (line.match(/height = (\d+),/)))
            @heights[header_idx] = m[1].to_i
          end
        end
      end
        
    elsif (type_code == 0x200100)
      # puts "  .. picture"

      # the actual data starts 
      data_pos = pos + 32
      yield @mem_buf[data_pos .. data_pos + length_of_data - 1], pos, @widths[idx], @heights[idx] if block_given?
    else
      puts "UNKNOWN type_code: #{type_code} / #{type_code_hex}"
    end
    
    res_next_offset = pos + 32 + length_of_data + length_of_padding
    if (res_next_offset >= @mem_buf.size)
      res_next_offset = -1
    end
    # puts "res_next_offset #{res_next_offset}, mem_buf.size #{@mem_buf.size}"
    
    res_next_offset
  end

  def parse
    idx = 0
    pos = 0

    while (pos >= 0)
      # puts "\n ** FOR POSITION #{pos}, INDEX #{idx} **"
      pos = parse_at_offset(idx, pos) do |buf, pos, width, height|
        #yield buf, width, height
        preview = Preview.new(pos, buf.size, width, height, buf)
        @previews.push(preview)
      end
      idx += 1
    end
  end
  
  def find_preview(longest_edge)
    res = nil
    @previews.each do |preview|
      if (preview.width >= longest_edge || preview.height >= longest_edge)
        res = preview
        break
      end
    end
    res
  end
  
end

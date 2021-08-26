module Pdf::Reader::ExtractImages
  class Raw
    attr_reader :stream

    def initialize(stream, data = stream.unfiltered_data)
      @stream = stream
      @data = data
    end

    def save(filename)
      case @stream.hash[:ColorSpace]
      when :DeviceCMYK then save_cmyk(filename)
      when :DeviceGray then save_gray(filename)
      when :DeviceRGB  then save_rgb(filename)
      else
        if @stream.hash[:ColorSpace].is_a?(Array)
          if @stream.hash[:ColorSpace].include?(:DeviceCMYK)
            return save_cmyk(filename)
          elsif @stream.hash[:ColorSpace].include?(:DeviceRGB)
            return save_rgb(filename)
          elsif @stream.hash[:ColorSpace].include?(:DeviceGray)
            return save_gray(filename)
          end
        end
        warn "unsupport color depth #{@stream.hash[:ColorSpace]} #{filename}"
      end
    end

    private

    def save_cmyk(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]

      # Synthesize a TIFF header
      long_tag  = ->(tag, count, value) { [tag, 4, count, value].pack("ssII") }
      short_tag = ->(tag, count, value) { [tag, 3, count, value].pack("ssII") }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 10
      header = [73, 73, 42, 8, tag_count].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call(256, 1, w) # image width
      tiff << short_tag.call(257, 1, h) # image height
      tiff << long_tag.call(258, 4, (header.size + (tag_count * 12) + 4)) # bits per pixel
      tiff << short_tag.call(259, 1, 1) # compression
      tiff << short_tag.call(262, 1, 5) # colorspace - separation
      tiff << long_tag.call(273, 1, (10 + (tag_count * 12) + 20)) # data offset
      tiff << short_tag.call(277, 1, 4) # samples per pixel
      tiff << long_tag.call(279, 1, @data.size) # data byte size
      tiff << short_tag.call(284, 1, 1) # planer config
      tiff << long_tag.call(332, 1, 1) # inkset - CMYK
      tiff << [0].pack("I") # next IFD pointer
      tiff << [bpc, bpc, bpc, bpc].pack("IIII")
      tiff << @data
      { filename: filename, blob: tiff, width: w, height: h }
    end

    def save_gray(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]

      # Synthesize a TIFF header
      long_tag  = ->(tag, count, value) { [tag, 4, count, value].pack("ssII") }
      short_tag = ->(tag, count, value) { [tag, 3, count, value].pack("ssII") }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 9
      header = [73, 73, 42, 8, tag_count].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call(256, 1, w) # image width
      tiff << short_tag.call(257, 1, h) # image height
      tiff << short_tag.call(258, 1, 8) # bits per pixel
      tiff << short_tag.call(259, 1, 1) # compression
      tiff << short_tag.call(262, 1, 1) # colorspace - grayscale
      tiff << long_tag.call(273, 1, (10 + (tag_count * 12) + 4)) # data offset
      tiff << short_tag.call(277, 1, 1) # samples per pixel
      tiff << long_tag.call(279, 1, stream.unfiltered_data.size) # data byte size
      tiff << short_tag.call(284, 1, 1) # planer config
      tiff << [0].pack("I") # next IFD pointer
      tiff << stream.unfiltered_data
      { filename: filename, blob: tiff, width: w, height: h }
    end

    def save_rgb(filename)
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      len  = stream.hash[:Length]

      # Synthesize a TIFF header
      long_tag  = ->(tag, count, value) { [tag, 4, count, value].pack("ssII") }
      short_tag = ->(tag, count, value) { [tag, 3, count, value].pack("ssII") }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata.
      tag_count = 8
      header = [73, 73, 42, 8, tag_count].pack("ccsIs")
      tiff = header.dup
      tiff << short_tag.call(256, 1, w) # image width
      tiff << short_tag.call(257, 1, h) # image height
      tiff << long_tag.call(258, 3, (header.size + (tag_count * 12) + 4)) # bits per pixel
      tiff << short_tag.call(259, 1, 1) # compression
      tiff << short_tag.call(262, 1, 2) # colorspace - RGB
      tiff << long_tag.call(273, 1, (header.size + (tag_count * 12) + 16)) # data offset
      tiff << short_tag.call(277, 1, 3) # samples per pixel
      tiff << long_tag.call(279, 1, stream.unfiltered_data.size) # data byte size
      tiff << [0].pack("I") # next IFD pointer
      tiff << [bpc, bpc, bpc].pack("III")
      tiff << stream.unfiltered_data
      { filename: filename, blob: tiff }
    end
  end
end


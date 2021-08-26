module Pdf::Reader::ExtractImages
  class Tiff
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def save(filename)
      k = stream.hash[:DecodeParms][:K]
      if !k.nil? && stream.hash[:DecodeParms][:K] <= 0
        save_group_four(filename)
      else
        warn "#{filename}: CCITT non-group 4/2D image."
      end
    end

    private

    # Group 4, 2D
    def save_group_four(filename)
      k    = stream.hash[:DecodeParms][:K]
      h    = stream.hash[:Height]
      w    = stream.hash[:Width]
      bpc  = stream.hash[:BitsPerComponent]
      mask = stream.hash[:ImageMask]
      len  = stream.hash[:Length]
      cols = stream.hash[:DecodeParms][:Columns]

      # Synthesize a TIFF header
      long_tag  = ->(tag, value) { [tag, 4, 1, value].pack("ssII") }
      short_tag = ->(tag, value) { [tag, 3, 1, value].pack("ssII") }
      # header = byte order, version magic, offset of directory, directory count,
      # followed by a series of tags containing metadata: 259 is a magic number for
      # the compression type; 273 is the offset of the image data.
      tiff = [73, 73, 42, 8, 5].pack("ccsIs") \
        + short_tag.call(256, cols) \
        + short_tag.call(257, h) \
        + short_tag.call(259, 4) \
        + long_tag.call(273, (10 + (5 * 12) + 4)) \
        + long_tag.call(279, len) \
        + [0].pack("I") \
        + stream.data
      { filename: filename, blob: tiff, width: w, height: h }
    end
  end
end
end



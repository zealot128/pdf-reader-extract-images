require 'image_processing'

module Pdf::Reader::ExtractImages
  class Jpg
    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def save(filename)
      w = stream.hash[:Width]
      h = stream.hash[:Height]
      blob = stream.data
      if stream.hash[:ColorSpace] == :DeviceCMYK && stream.data['Adobe']
        blob = Tempfile.open(['extract', filename]) { |tf|
          tf.binmode
          tf.write stream.data
          tf.flush
          ImageProcessing::MiniMagick.source(tf.path).negate.call.read
        }
      end
      { filename: filename, blob: blob, width: w, height: h }
    end
  end
end

module Pdf::Reader::ExtractImages
  class Extractor
    def initialize(limit = Float::INFINITY)
      @images = []
      @limit = limit
    end

    def page(page)
      process_page(page, 0)
      @images.compact!
      @images
    end

    private

    def complete_refs
      @complete_refs ||= {}
    end

    def process_page(page, count)
      xobjects = page.xobjects
      return count if xobjects.empty?

      xobjects.each do |name, stream|
        return if @images.length > @limit

        case stream.hash[:Subtype]
        when :Image then
          count += 1
          number = page.respond_to?(:number) ? page.number : 1

          @images << extract_image_from_stream(stream, filename: "#{number}-#{count}-#{name}")
        when :Form then
          if page.respond_to?(:objects)
            count = process_page(PDF::Reader::FormXObject.new(page, stream), count)
          end
        end
      end
      count
    end

    def extract_image_from_stream(stream, filename:)
      case stream.hash[:Filter]
      when :CCITTFaxDecode
        begin
          Tiff.new(stream).save("#{filename}.tif")
        rescue PDF::Reader::MalformedPDFError
          nil
        end
      when :DCTDecode
        Jpg.new(stream).save("#{filename}.jpg")
      when [:FlateDecode, :DCTDecode], :FlateDecode
        unzipped = Zlib::Inflate.inflate(stream.data)
        if stream.hash[:ColorSpace]
          Raw.new(stream, unzipped).save("#{filename}.tif")
        else
          {
            blob: unzipped,
            width: stream.hash[:Width],
            height: stream.hash[:Height],
            filename: "#{filename}.jpg"
          }
        end
      else
        begin
          Raw.new(stream).save("#{filename}.tif")
        rescue PDF::Reader::MalformedPDFError
          nil
        end
      end
    end
  end
end

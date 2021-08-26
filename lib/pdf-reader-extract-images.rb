require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore(__FILE__)
loader.setup

module Pdf::Reader
  module ExtractImages
    def self.extract_from_pdf_page(page, limit: Float::INFINITY)
      Extractor(limit).new.page(page)
    end

    def self.extract_all(pdf_reader, limit: Float::INFINITY)
      pdf_reader.pages.flat_map { |page| Extractor.new(limit).page(page) }.compact
    end
  end
end


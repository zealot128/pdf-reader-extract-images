# Pdf::Reader::Extract::Images

ExtractImages

Based upon the [Example from Pdf::Reader](https://github.com/yob/pdf-reader/blob/main/examples/extract_images.rb), battle hardened in our applicant tracking system with tens of thousands of PDFs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pdf-reader-extract-images'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pdf-reader-extract-images

## Usage

```ruby
require 'pdf-reader-extract-images'

reader = PDF::Reader.new(pdf)
images = Pdf::Reader::ExtractImages.extract_all(reader)

# pass an image limit to ignore gigantic image-only pdfs
images = Pdf::Reader::ExtractImages.extract_all(reader, limit: 50)

# [
#  {
#    :filename => "1-1-Im1.jpg",
#    :width => 1772,
#    :height => 591
#    :blob => "....",
#  }
# ]

# OR you can just scan a single Pdf::Reader Page

reader.pages.each do |page|
  images = Pdf::Reader::ExtractImages.extract_from_pdf_page(page)
end
```

## Limitations

There are some PDFs which have tons of images. Make sure to limit the timeout of an extraction somehow.

Also some PDFs product hundreds of images. Make sure to limit further processing down the line

Unfortunately, there is no public test suite. We have a private test suite that tests live pdfs which we cannot share. If you'd like to contribute problematic PDFs, feel free to open PR!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

require 'tilt/prawn'
require 'pdf-reader'

describe Tilt::PrawnTemplate do
  class PdfOutput
    def initialize(pdf_raw)
      @reader = PDF::Reader.new(StringIO.new(pdf_raw))
    end

    def text
      @reader.pages.map(&:text).join
    end
  end

  describe 'string templates' do
    it 'renders basic' do
      template = Tilt::PrawnTemplate.new { 'pdf.text "Hello World"' }

      output = PdfOutput.new(template.render)
      expect(output.text).to include('Hello World')
    end
  end

  describe 'block templates' do
    it 'renders basic' do
      template = Tilt::PrawnTemplate.new do |pdf|
        ->(pdf) { pdf.text "Hello World" }
      end

      output = PdfOutput.new(template.render)
      expect(output.text).to include('Hello World')
    end
  end
end

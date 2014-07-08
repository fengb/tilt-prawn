require 'tilt/prawn'

require 'pdf-reader'
require 'ostruct'

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

    it 'renders scope methods' do
      template = Tilt::PrawnTemplate.new { 'pdf.text foo' }

      output = PdfOutput.new(template.render(OpenStruct.new(foo: 'Zeo')))
      expect(output.text).to include('Zeo')
    end

    it 'renders local variables' do
      template = Tilt::PrawnTemplate.new { 'pdf.text foo' }

      output = PdfOutput.new(template.render(Object.new, foo: 'Small Worlds'))
      expect(output.text).to include('Small Worlds')
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

    it 'renders scope methods' do
      template = Tilt::PrawnTemplate.new do |pdf|
        ->(pdf) { pdf.text foo }
      end

      output = PdfOutput.new(template.render(OpenStruct.new(foo: 'Zeo')))
      expect(output.text).to include('Zeo')
    end

    it 'renders local variables' do
      template = Tilt::PrawnTemplate.new do |pdf|
        ->(pdf) { pdf.text foo }
      end

      output = PdfOutput.new(template.render(Object.new, foo: 'Small Worlds'))
      expect(output.text).to include('Small Worlds')
    end
  end
end

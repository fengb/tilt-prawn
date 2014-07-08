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

    describe 'arbitrary ruby' do
      it 'renders methods' do
        template = Tilt::PrawnTemplate.new do
          <<-END
            def foo
              'story'
            end

            pdf.text foo
          END
        end

        output = PdfOutput.new(template.render)
        expect(output.text).to include('story')
      end

      it 'renders classes' do
        template = Tilt::PrawnTemplate.new do
          <<-END
            class Bob < String
            end

            pdf.text Bob.new('forty')
          END
        end

        output = PdfOutput.new(template.render)
        expect(output.text).to include('forty')
      end

      it 'does not bleed out the enclosing scope' do
        pending 'class bleeds out to Tilt::PrawnTemplate'
        scope = Object.new
        template = Tilt::PrawnTemplate.new do
          <<-END
            def foo
              'story'
            end

            class Foo
            end
          END
        end

        template.render
        expect(scope).to_not respond_to(:foo)
        expect(Object).to_not be_const_defined(:Foo)
        expect(Tilt::PrawnTemplate).to_not be_const_defined(:Foo)
      end
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

    describe 'arbitrary ruby' do
      it 'renders methods' do
        template = Tilt::PrawnTemplate.new do |pdf|
          Proc.new do |pdf|
            def foo
              'story'
            end

            pdf.text foo
          end
        end

        output = PdfOutput.new(template.render)
        expect(output.text).to include('story')
      end

      it 'renders classes' do
        template = Tilt::PrawnTemplate.new do |pdf|
          Proc.new do |pdf|
            class Bob < String
            end

            pdf.text Bob.new('forty')
          end
        end

        output = PdfOutput.new(template.render)
        expect(output.text).to include('forty')
      end

      it 'does not bleed out the enclosing scope' do
        pending 'classes bleed out to Tilt::PrawnTemplate'
        scope = Object.new
        template = Tilt::PrawnTemplate.new do |pdf|
          Proc.new do |pdf|
            def foo
              'story'
            end

            class Foo
            end
          end
        end

        template.render
        expect(scope).to_not respond_to(:foo)
        expect(Object).to_not be_const_defined(:Foo)
        expect(Tilt::PrawnTemplate).to_not be_const_defined(:Foo)
      end
    end
  end
end

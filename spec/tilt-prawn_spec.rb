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

  it 'is registered for .prawn files' do
    expect(Tilt['foo.prawn']).to be(described_class)
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
      it 'renders methods without bleeding out' do
        template = Tilt::PrawnTemplate.new do
          <<-END
            def foo
              'story'
            end

            pdf.text foo
          END
        end

        scope = Object.new

        output = PdfOutput.new(template.render(scope))
        expect(output.text).to include('story')
        expect(scope).to_not respond_to(:foo)
      end

      it 'renders classes without bleeding out' do
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
      it 'renders methods without bleeding out' do
        template = Tilt::PrawnTemplate.new do |pdf|
          Proc.new do |pdf|
            def foo
              'story'
            end

            pdf.text foo
          end
        end

        scope = Object.new

        output = PdfOutput.new(template.render(scope))
        expect(output.text).to include('story')
        expect(scope).to_not respond_to(:foo)
      end

      it 'renders classes without bleeding out' do
        pending 'currently bleeds out to Tilt::PrawnTemplate'

        template = Tilt::PrawnTemplate.new do |pdf|
          Proc.new do |pdf|
            class Bob < String
            end

            pdf.text Bob.new('forty')
          end
        end

        output = PdfOutput.new(template.render)
        expect(output.text).to include('forty')
        expect(Object).to_not be_const_defined(:Bob)
        expect(Tilt::PrawnTemplate).to_not be_const_defined(:Bob)
      end
    end
  end

  context 'configuration' do
    class TestEngine < ::Prawn::Document
      def beer(times)
        text 'beer'*times
      end
    end

    after do
      Tilt::PrawnTemplate.reset_engine!
    end

    it 'can swap out .engine' do
      Tilt::PrawnTemplate.engine = TestEngine
      template = Tilt::PrawnTemplate.new { 'pdf.beer 3' }

      output = PdfOutput.new(template.render)
      expect(output.text).to include('beerbeerbeer')
    end

    it 'can .extend_engine' do
      Tilt::PrawnTemplate.extend_engine do
        def eat
          text 'EAAAAT'
        end
      end
      template = Tilt::PrawnTemplate.new { 'pdf.eat' }

      output = PdfOutput.new(template.render)
      expect(output.text).to include('EAAAAT')
    end

    it 'can use options[:engine]' do
      template = Tilt::PrawnTemplate.new(engine: TestEngine) { 'pdf.beer 2' }
      output = PdfOutput.new(template.render)
      expect(output.text).to include('beerbeer')
    end
  end
end

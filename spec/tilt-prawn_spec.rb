require 'tilt/prawn'

describe Tilt::PrawnTemplate do
  pdf = /^\%PDF-1.3/
  it 'renders string templates' do
    template = Tilt::PrawnTemplate.new { 'pdf.text "Hello World"' }
    expect(template.render).to match(pdf)
  end

  it 'renders block templates' do
    template = Tilt::PrawnTemplate.new do |pdf|
      ->(pdf) { pdf.text "Hello World" }
    end
    expect(template.render).to match(pdf)
  end
end

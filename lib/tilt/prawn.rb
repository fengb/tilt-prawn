require 'tilt'
require 'prawn'
require 'tilt/prawn/version'

module Tilt
  class PrawnTemplate < Template
    self.default_mime_type = 'application/pdf'

    def prepare
    end

    def evaluate(scope, locals, &block)
      scope = scope ? scope.dup : BasicObject.new
      pdf = ::Prawn::Document.new
      if data.respond_to?(:call)
        locals.each do |key, val|
          scope.define_singleton_method(key) { val }
        end
        scope.instance_exec(pdf, &data)
      else
        locals[:pdf] = pdf
        super(scope, locals, &block)
      end
      pdf.render
    end

    def precompiled_template(local_keys)
      data
    end
  end

  register PrawnTemplate, 'prawn'
end

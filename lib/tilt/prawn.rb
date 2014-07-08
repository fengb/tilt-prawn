require 'tilt'
require 'prawn'
require 'tilt/prawn/version'

module Tilt
  class PrawnTemplate < Template
    self.default_mime_type = 'application/pdf'

    def self.engine_initialized?
      defined? ::Prawn::Document
    end

    def initialize_engine
      require_template_library 'prawn'
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      doc = ::Prawn::Document.new do |pdf|
        if data.respond_to?(:call)
          # preserve scope object on caller
          scope = scope.dup
          locals.each do |key, val|
            scope.define_singleton_method(key) { val }
          end
          scope.instance_exec(pdf, &data)
        else
          context = scope.instance_eval { binding }
          locals.each do |key, val|
            context.local_variable_set(key, val)
          end
          context.eval(data)
        end
      end
      doc.render
    end
  end
end

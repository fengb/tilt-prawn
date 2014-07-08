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
      doc =
        if data.respond_to?(:call)
          ::Prawn::Document.new(&data)
        else
          ::Prawn::Document.new do |pdf|
            context = scope.instance_eval { binding }
            eval(data, context)
          end
        end
      doc.render
    end
  end
end

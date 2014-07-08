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
          scope = scope.dup # preserve scope object on caller
          locals.each do |key, val|
            scope.define_singleton_method(key) { val }
          end
          scope.instance_exec(pdf, &data)
        else
          context = scope.instance_eval { binding }
          if context.respond_to?(:local_variable_set)
            locals.each do |key, val|
              context.local_variable_set(key, val)
            end
          else
            locals.each do |key, val|
              # Wow, what a hack
              context.eval("#{key} = #{val.inspect}")
            end
          end
          context.eval(data)
        end
      end
      doc.render
    end
  end
end

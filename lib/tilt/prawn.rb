require 'tilt'
require 'prawn'
require 'tilt/prawn/version'

module Tilt
  class PrawnTemplate < Template
    class Engine < ::Prawn::Document
    end

    class << self
      attr_accessor :engine

      def reset_engine!
        self.engine = Engine
        Engine.instance_methods(false).each do |method|
          Engine.send(:undef_method, method)
        end
      end
    end

    self.default_mime_type = 'application/pdf'
    self.reset_engine!

    def self.extend_engine(&block)
      Engine.class_eval(&block)
    end

    def prepare
    end

    def engine
      @options[:engine] || self.class.engine
    end

    def evaluate(scope, locals, &block)
      scope = scope ? scope.dup : BasicObject.new
      pdf = engine.new
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

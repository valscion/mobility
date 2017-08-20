require "mobility/plugins/cache"
require "mobility/backends/table"

module Mobility
  module Backends
    module OwnTable
      extend Backend::OrmDelegator

      # @return [Symbol] name of the association method
      attr_reader :association_name

      # @!macro backend_constructor
      # @option options [Symbol] association_name Name of association
      def initialize(model, attribute, options = {})
        super
        @association_name = options[:association_name]
      end

      # @!macro backend_iterator
      def each_locale
        translations.each { |t| yield t.locale.to_sym }
      end

      private

      def translations
        model.send(association_name)
      end

      def self.included(backend)
        backend.extend ClassMethods
      end

      module ClassMethods
        # Apply custom processing for plugin
        # @param (see Backend::Setup#apply_plugin)
        # @return (see Backend::Setup#apply_plugin)
        def apply_plugin(name)
          if name == :cache
            include Table::Cache
            true
          else
            super
          end
        end
      end
    end
  end
end

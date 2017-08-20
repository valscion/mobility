require "mobility/backends/active_record"
require "mobility/backends/own_table"

module Mobility
  module Backends
    class ActiveRecord::OwnTable
      include ActiveRecord
      include OwnTable

      def read(locale, options = {})
        translation_for(locale, options).read_attribute(attribute)
      end

      def write(locale, value, options = {})
        translation_for(locale, options).send(:write_attribute, attribute, value)
      end

      def self.configure(options)
        options[:association_name] ||= :translations
        table_name = options[:model_class].table_name
        options[:foreign_key] ||= :"source_#{table_name.downcase.singularize.camelize.foreign_key}"
      end

      setup do |_attribute, options|
        association_name = options[:association_name]
        foreign_key      = options[:foreign_key]

        after_initialize do
          self.locale = Mobility.locale.to_s if locale.nil?
        end

        has_many association_name, class_name: name, foreign_key: foreign_key
      end

      private

      def translation_for(locale, _)
        return model if (model.locale.nil? || model.locale == locale.to_s)
        translation = translations.find { |t| t.locale == locale.to_s }
        translation ||= translations.build(locale: locale)
        translation
      end

      def translations
        model.send(association_name)
      end
    end
  end
end

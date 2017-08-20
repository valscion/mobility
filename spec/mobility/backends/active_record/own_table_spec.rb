require "spec_helper"

describe "Mobility::Backends::ActiveRecord::OwnTable", orm: :active_record do
  require "mobility/backends/active_record/own_table"
  extend Helpers::ActiveRecord

  before do
    stub_const 'Product', Class.new(ActiveRecord::Base)
    Product.extend Mobility
  end

  context "with no plugins applied" do
    include_backend_examples described_class, 'Product', 'name'
  end

  context "without cache" do
    before { Product.translates :name, :description, backend: :own_table, cache: false }
    include_accessor_examples "Product", "name", "description"

    it "creates correct number of records" do
      product = Product.new
      product.name_backend.write(:en, "foo name")
      product.description_backend.write(:en, "foo description")
      product.name_backend.write(:fr, "bar name")
      product.description_backend.write(:fr, "bar description")
      product.save
      expect(Product.count).to eq(2)

      product = Product.first
      expect(product.name).to eq("foo name")
      expect(product.description).to eq("foo description")
      expect(product.translations.count).to eq(1)
      expect(product.translations.first.read_attribute :name).to eq("bar name")
      expect(product.translations.first.read_attribute :description).to eq("bar description")
    end
  end

  context "with cache" do
    before { Product.translates :name, :description, backend: :own_table, cache: true }
    include_accessor_examples "Product", "name", "description"
  end
end

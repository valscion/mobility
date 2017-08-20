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
  end

  context "with cache" do
    before { Product.translates :name, :description, backend: :own_table, cache: true }
    include_accessor_examples "Product", "name", "description"
  end
end

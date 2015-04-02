module Fakturan
  class Row < Base
    uri nil

    attributes :product_id, :discount, :amount, :text, :product_code, :product_name, :product_unit, :product_price, :product_tax, :text_row, :sort_order
  end
end
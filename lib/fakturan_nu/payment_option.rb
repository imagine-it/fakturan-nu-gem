module Fakturan
  class PaymentOption < Base
    uri nil

    attributes :type, :pg, :bg
    belongs_to :setting
  end
end
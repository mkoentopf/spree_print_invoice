include Forwardable

module Spree
  class Printables::Invoice::BaseView < Printables::BaseView
    extend Forwardable
    extend Spree::DisplayMoney

    attr_reader :printable

    money_methods :item_total, :total

    def bill_address
      raise NotImplementedError, 'Please implement bill_address'
    end

    def ship_address
      raise NotImplementedError, 'Please implement ship_address'
    end

    def tax_address
      raise NotImplementedError, 'Please implement tax_address'
    end

    def items
      raise NotImplementedError, 'Please implement items'
    end

    def item_total
      raise NotImplementedError, 'Please implement item_total'
    end

    def adjustments
      adjustments = []
      all_adjustments.group_by(&:label).each do |label, adjustment_group|
        adjustments << Spree::Printables::Invoice::Adjustment.new(
          label: label,
          amount: adjustment_group.map(&:amount).sum
        )
      end
      adjustments
    end

    def shipments
      raise NotImplementedError, 'Please implement shipments'
    end

    def payments
      raise NotImplementedError, 'Please implement payments'
    end

    def shipping_methods
      shipments.map(&:shipping_method).map(&:name)
    end

    def number(number = next_number)
      if use_sequential_number?
        formatted_number(number)
      else
        printable.number
      end
    end

    def formatted_number(number = next_number)
      if (Object.const_get('::Spree::PrintInvoice::NumberFormatter') rescue false)
        ::Spree::PrintInvoice::NumberFormatter.new(number).to_s
      else
        number
      end
    end

    private

    def next_number
      Spree::PrintInvoice::Config.next_number
    end

    def use_sequential_number?
      @_use_sequential_number ||=
        Spree::PrintInvoice::Config.use_sequential_number?
    end
  end
end

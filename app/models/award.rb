class Award < ApplicationRecord
  belongs_to :organization, foreign_key: "recipient_id", primary_key: "id"

  def self.from_xml(node, tax_period, recipient_id)
    # purpose
    purpose_node = node.css("PurposeOfGrantTxt")[0]
    if purpose_node.nil?
      raise "Found award without a <PurposeOfGrantTxt>."
    end
    purpose = purpose_node.text
    # cash_amount
    cash_amount_node = node.css("CashGrantAmt")[0]
    if cash_amount_node.nil?
      raise "Found award without a <CashGrantAmt>."
    end
    cash_amount = cash_amount_node.text.to_i

    return Award.new(purpose: purpose, cash_amount: cash_amount, tax_period: tax_period, recipient_id: recipient_id)
  end
end

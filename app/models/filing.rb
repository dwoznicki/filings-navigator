class Filing < ApplicationRecord
  belongs_to :organization, foreign_key: "filer_id"

  def self.from_xml(node, filer_id)
    # TODO: Raise exceptions with a proper type instead of runtime exceptions.

    # tax period
    tax_period_node = node.css("TaxPeriodEndDt")[0]
    if tax_period_node.nil?
      tax_period_node = node.css("TaxPeriodEndDate")[0]
    end
    if tax_period_node.nil?
      raise "Found filing without a <TaxPeriodEndDt> or <TaxPeriodEndDate>."
    end
    tax_period = tax_period_node.text.to_date
    # return time
    return_timestamp_node = node.css("ReturnTs")[0]
    if return_timestamp_node.nil?
      raise "Found filing without a <ReturnTs>."
    end
    return_time = return_timestamp_node.text.to_datetime
    # amended
    # Check if any nodes in the document contain an amended indicator.
    amended = !node.document.root.css("AmendedReturnInd").empty?

    return Filing.new(tax_period: tax_period, return_time: return_time, amended: amended, filer_id: filer_id)
  end
end
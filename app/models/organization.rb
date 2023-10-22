class Organization < ApplicationRecord
  has_many :filings, foreign_key: "filer_id"
  has_many :awards, foreign_key: "recipient_id"

  def self.from_xml(node)
    # TODO: Raise exceptions with a proper type instead of runtime exceptions.

    # ein
    ein_node = node.css("EIN")[0]
    # NOTE: I don't think it will cause issues to check for recipient specific nodes, even if the
    # input is a filer node. Nevertheless, I might choose to split `from_xml` into two functions
    # (`from_filer_xml` and `from_recipient_xml`) so I could ensure there's no unexpected overlap.
    if ein_node.nil?
      ein_node = node.css("EINOfRecipient")[0]
    end
    if ein_node.nil?
      ein_node = node.css("RecipientEIN")[0]
    end
    ein = nil
    # EIN can be nil.
    if not ein_node.nil?
      ein = ein_node.text.to_i
    end
    # name
    name_node = node.css("Name BusinessNameLine1")[0]
    if name_node.nil?
      name_node = node.css("BusinessName BusinessNameLine1Txt")[0]
    end
    # NOTE: Mixing filer/recipient names. See note above.
    if name_node.nil?
      name_node = node.css("RecipientNameBusiness BusinessNameLine1")[0]
    end
    if name_node.nil?
      name_node = node.css("RecipientBusinessName BusinessNameLine1Txt")[0]
    end
    if name_node.nil?
      raise "Found organization without a <Name>/<BusinessNameLine1>, <BusinessName>/<BusinessNameLine1Txt>, <RecipientNameBusiness>/<BusinessNameLine1>, or <RecipientBusinessName>/<BusinessNameLine1Txt>."
    end
    name = name_node.text
    # address
    address_node = node.css("USAddress")[0]
    if address_node.nil?
      address_node = node.css("AddressUS")[0]
    end
    if address_node.nil?
      raise "Found organization without a <USAddress> or <AddressUS>."
    end
    # address line1
    address_line1_node = address_node.css("AddressLine1")[0]
    if address_line1_node.nil?
      address_line1_node = address_node.css("AddressLine1Txt")[0]
    end
    if address_line1_node.nil?
      raise "Found organization without a <AddressLine1> or <AddressLine1Txt>."
    end
    address_line1 = address_line1_node.text
    # city
    city_node = address_node.css("City")[0]
    if city_node.nil?
      city_node = address_node.css("CityNm")[0]
    end
    if city_node.nil?
      raise "Found organization without a <City> or <CityNm>."
    end
    city = city_node.text
    # state
    state_node = address_node.css("State")[0]
    if state_node.nil?
      state_node = address_node.css("StateAbbreviationCd")[0]
    end
    if state_node.nil?
      raise "Found organization without a <State> or <StateAbbreviationCd>."
    end
    state_code = state_node.text
    # zip
    zip_node = address_node.css("ZIPCode")[0]
    if zip_node.nil?
      zip_node = address_node.css("ZIPCd")[0]
    end
    if zip_node.nil?
      raise "Found organization without a <ZIPCode> or <ZIPCd>."
    end
    zip_code = zip_node.text

    return Organization.new(ein: ein, name: name, address_line1: address_line1, city: city, state_code: state_code, zip_code: zip_code)
  end
end

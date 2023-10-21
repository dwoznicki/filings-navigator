class Organization < ApplicationRecord
  self.primary_key = "ein"
  has_many :filings, foreign_key: "filer_ein"
  has_many :awards, foreign_key: "recipient_ein"
end

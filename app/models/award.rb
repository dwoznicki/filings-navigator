class Award < ApplicationRecord
  belongs_to :organization, foreign_key: "recipient_ein", primary_key: "ein"
end

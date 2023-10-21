class Filing < ApplicationRecord
  belongs_to :organization, foreign_key: "filer_ein", primary_key: "ein"
end

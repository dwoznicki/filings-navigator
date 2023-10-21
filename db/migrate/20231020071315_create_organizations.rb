class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations, id: false do |t|
      t.primary_key :ein, :integer
      t.text :name
      t.text :address_line1
      t.text :city
      t.string :state_code, limit: 2
      t.string :zip_code, limit: 10

      t.timestamps
    end
  end
end

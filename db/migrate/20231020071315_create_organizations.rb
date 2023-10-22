class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.integer :ein
      t.text :name, null: false
      t.text :address_line1, null: false
      t.text :city, null: false
      t.string :state_code, null: false, limit: 2
      t.string :zip_code, null: false, limit: 10

      t.timestamps
    end
    # NOTE: The goal of this unique index is to prevent duplicate organization records. It's
    # possible that this index will produce a false positive error if there exists two organizations
    # with the same name, and neither has an EIN. I think this is unlikely, but I'd have to talk
    # with someone with more domain knowledge to know for sure. If that were the case, we'd need to
    # add the address fields to the index as well.
    add_index :organizations, [:ein, :name], unique: true
  end
end

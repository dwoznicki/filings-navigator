class CreateAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :awards do |t|
      t.text :purpose, null: false
      t.integer :cash_amount, null: false
      t.date :tax_period, null: false
      t.integer :recipient_id, null: false

      t.timestamps
    end
    add_foreign_key :awards, :organizations, column: :recipient_id, primary_key: "id"
  end
end

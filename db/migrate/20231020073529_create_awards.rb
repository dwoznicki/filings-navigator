class CreateAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :awards do |t|
      t.text :purpose
      t.integer :cash_amount
      t.date :tax_period
      t.integer :recipient_ein

      t.timestamps
    end
    add_foreign_key :awards, :organizations, column: :recipient_ein, primary_key: "ein"
  end
end

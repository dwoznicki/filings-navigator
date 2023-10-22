class CreateFilings < ActiveRecord::Migration[7.0]
  def change
    create_table :filings do |t|
      t.datetime :return_time, null: false
      t.date :tax_period, null: false
      t.integer :filer_id, null: false

      t.timestamps
    end
    add_foreign_key :filings, :organizations, column: :filer_id, primary_key: "id"
    add_index :filings, [:return_time, :tax_period, :filer_id], unique: true
  end
end

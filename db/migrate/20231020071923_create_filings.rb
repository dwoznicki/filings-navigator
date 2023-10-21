class CreateFilings < ActiveRecord::Migration[7.0]
  def change
    create_table :filings do |t|
      t.datetime :return_time
      t.date :tax_period
      t.integer :filer_ein

      t.timestamps
    end
    add_foreign_key :filings, :organizations, column: :filer_ein, primary_key: "ein"
  end
end

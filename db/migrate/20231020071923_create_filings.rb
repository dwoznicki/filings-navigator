class CreateFilings < ActiveRecord::Migration[7.0]
  def change
    create_table :filings do |t|
      t.date :tax_period, null: false
      t.datetime :return_time, null: false
      t.boolean :amended, null: false
      t.integer :filer_id, null: false

      t.timestamps
    end
    add_foreign_key :filings, :organizations, column: :filer_id, primary_key: "id"
    # Each filing should be unique on all columns. Only one filing is considered valid per
    # filer/tax period combination. If there are multiple filings within a given tax period, we can
    # deetermine which is valid like so.
    #   - Filings with an amended indicator beat out others within the same tax period.
    #   - Filings with a later return time beat others with an earlier return time.
    # We'll keep all filings around, and let the application determine which is valid.
    add_index :filings, [:tax_period, :return_time, :amended, :filer_id], unique: true, name: "filings_unique_idx"
  end
end

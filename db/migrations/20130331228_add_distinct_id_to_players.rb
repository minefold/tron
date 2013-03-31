Sequel.migration do
  change do
    alter_table(:players) do
      add_column :distinct_id, String, null: true, index: true
      drop_index :username
    end
  end
end

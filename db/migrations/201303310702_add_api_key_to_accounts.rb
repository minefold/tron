Sequel.migration do
  change do
    alter_table(:accounts) do
      add_column :api_key, String, size: 32, null: true, index: {unique: true}
    end
  end
end

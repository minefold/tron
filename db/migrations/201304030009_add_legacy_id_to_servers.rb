Sequel.migration do
  change do
    alter_table(:servers) do
      add_column :legacy_id, String, text: false,
                                     size: 24,
                                     null: true,
                                     index: {unique: true}
    end
  end
end

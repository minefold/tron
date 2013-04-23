Sequel.migration do
  change do
    alter_table(:sessions) do
      add_column :exit_status, Integer, null: true
    end
  end
end

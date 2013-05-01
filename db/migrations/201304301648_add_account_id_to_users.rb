Sequel.migration do
  change do
    alter_table(:users) do
      add_foreign_key :account_id, :accounts, :type => :uuid, null: false
    end
  end
end

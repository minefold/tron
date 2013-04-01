Sequel.migration do
  change do
    create_table(:regions) do
      primary_key :id, :type => :uuid
      String :name, null: false
    end

    alter_table(:servers) do
      add_foreign_key :region_id, :regions, :type => :uuid, null: false
    end
  end
end

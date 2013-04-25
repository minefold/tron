Sequel.migration do
  change do
    create_table :users do
      primary_key :id, :type => :uuid

      String :email, text: false, unique: true, null: false
      String :encrypted_password, text: false, null: false, length: 40

      DateTime :created, null: false
      DateTime :updated, null: false
    end
  end
end

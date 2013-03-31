Sequel.migration do
  change do
    create_table :accounts do
      primary_key :id, :type => :uuid
      String  :email, null: false

      DateTime :created, null: false
      DateTime :updated, null: false
    end

    create_table :funpacks do
      primary_key :id, :type => :uuid
      foreign_key :account_id, :accounts, :type => :uuid, null: false

      String   :name, null: false

      DateTime :created, null: false
      DateTime :updated, null: false
    end

    create_table :players do
      primary_key :id, :type => :uuid
      foreign_key :account_id, :accounts, :type => :uuid, null: false

      String   :username, null: true
      String   :email, null: true

      DateTime :created, null: false
      DateTime :updated, null: false

      index :username
    end

    create_table :regions do
      primary_key :id, :type => :uuid
      String :name, null: false
    end

    create_table :servers do
      primary_key :id, :type => :uuid
      foreign_key :account_id, :accounts, :type => :uuid, null: false
      foreign_key :funpack_id, :funpacks, :type => :uuid, null: false
      foreign_key :region_id, :regions, :type => :uuid, null: false
      foreign_key :owner_id, :players, :type => :uuid, null: true

      Integer :state, null: false

      String  :name, null: true

      DateTime :created, null: false
      DateTime :updated, null: false
    end

    create_table :sessions do
      primary_key :id, :type => :uuid
      foreign_key :server_id, :servers, :type => :uuid, null: false

      String   :payload, text: true

      DateTime :created, null: false
      DateTime :updated, null: false

      DateTime :started, null: true
      DateTime :stopped, null: true

      inet    :ip
      Integer :port
    end

    create_table :player_sessions do
      primary_key :id, :type => :uuid
      foreign_key :session_id, :sessions, :type => :uuid, null: false
      foreign_key :player_id, :players, :type => :uuid, null: false

      DateTime :started, null: false
      DateTime :stopped
    end

    create_table :snapshots do
      primary_key :id, :type => :uuid
      foreign_key :server_id, :servers, :type => :uuid, null: false

      Integer  :size

      DateTime :created, null: false
      DateTime :updated, null: false
    end

  end
end

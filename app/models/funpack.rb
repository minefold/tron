class Funpack < Sequel::Model
  many_to_one :account
  one_to_many :servers

  def validate
    validates_presence [:id, :account, :name]
    validates_unique :id, :name
  end

  def server_count
    Server.where(funpack: self).count
  end
  
  def legacy_id
    {
      # minecraft
      '50a976ec7aae5741bb000001' => '9ed10c25-60ed-4375-8170-29f9365216a0',
      # bukkit-essentials
      '50a976fb7aae5741bb000002' => 'c942cbc1-05b2-4928-8695-b0d2a4d7b452',
      # tekkit
      '50a977097aae5741bb000003' => '4bfcf174-e630-43d4-a17a-3c0d1491bae4',
      # team-fortress-2
      '50bec3967aae5797c0000004' => '3fe55a6d-36fe-4e27-9ba3-1309e6405aa5',
      # feed-the-beast-direwolf20
      '512159a67aae57bf17000005' => '2f203313-cc51-4ae2-88b5-9d35620d8ef2',
      # tekkit-lite
      '5126be367aae5712a4000007' => 'a3ef2208-65df-4bc0-934c-e80e1bd7914f'
    }.invert.fetch(id)
  end

end

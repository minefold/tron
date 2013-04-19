require "sequel"
require "securerandom"

# connect to an in-memory database
DB = Sequel.connect(ENV['DATABASE_URL'])

account_id = 'dd19ed91-9d97-4ece-80d3-afd45f196002'
api_key = 'ZJuPqeia7rRY5yMF9HsTYooX0VvmuhEk'

DB[:accounts].insert(
  id: account_id, 
  api_key: api_key,
  email: 'dev@example.com',
  created: Time.now, 
  updated: Time.now
)


{
  'minecraft'                 => '9ed10c25-60ed-4375-8170-29f9365216a0',
  'bukkit-essentials'         => 'c942cbc1-05b2-4928-8695-b0d2a4d7b452',
  'tekkit'                    => '4bfcf174-e630-43d4-a17a-3c0d1491bae4',
  'team-fortress-2'           => '3fe55a6d-36fe-4e27-9ba3-1309e6405aa5',
  'feed-the-beast-direwolf20' => '2f203313-cc51-4ae2-88b5-9d35620d8ef2',
  'tekkit-lite'               => 'a3ef2208-65df-4bc0-934c-e80e1bd7914f'
}.each do |name, id|
  DB[:funpacks].insert(
    id: id,
    account_id: account_id,
    name: name,
    created: Time.now,
    updated: Time.now
  )
end

DB[:regions].insert(
  id: '71519ec0-1515-42b9-b2f6-a24c151a6247',
  name: 'us-east-1',
)

puts "Dev key: #{api_key}"
require_relative './lib/sql_object'

DEMO_DB = 'farms.db'
DEMO_SQL = 'farms.sql'

`rm '#{DEMO_DB}'`
`cat '#{DEMO_SQL}' | sqlite3 '#{DEMO_DB}'`

DBConnection.open(DEMO_DB)

class Chicken < SQLObject
  belongs_to :owner, class_name: 'Farmer'

  finalize!
end

class Cow < SQLObject
  belongs_to :owner, class_name: 'Farmer'

  finalize!
end

class Farmer < SQLObject
  has_many :cows, foreign_key: :owner_id
  has_many :chickens, foreign_key: :owner_id

  belongs_to :farm

  finalize!
end

class Farm < SQLObject
  has_many :farmers

  finalize!
end

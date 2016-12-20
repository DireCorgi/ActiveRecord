require_relative './lib/sql_object'

DEMO_DB = 'farms.db'
DEMO_SQL = 'farms.sql'

`rm '#{DEMO_DB}'`
`cat '#{DEMO_SQL}' | sqlite3 '#{DEMO_DB}'`

DBConnection.open(DEMO_DB)

class Chicken < SQLObject
  validates :name, :color, presence: true

  belongs_to :owner, class_name: 'Farmer'
  has_one_through :farm, :owner, :farm

  finalize!
end

class Cow < SQLObject
  validates :name, :color, presence: true

  belongs_to :owner, class_name: 'Farmer'
  has_one_through :farm, :owner, :farm

  finalize!
end

class Farmer < SQLObject
  validates :fname, :lname, :age, presence: true

  has_many :cows, foreign_key: :owner_id
  has_many :chickens, foreign_key: :owner_id

  belongs_to :farm

  finalize!
end

class Farm < SQLObject
  validates :name, :state, presence: true
  validates :name, length: { minimum: 5, maximum: 24 }, uniqueness: true

  has_many :farmers

  finalize!
end

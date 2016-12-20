require_relative './lib/sql_object'

DEMO_DB = 'farms.db'
DEMO_SQL = 'farms.sql'

`rm '#{DEMO_DB}'`
`cat '#{DEMO_SQL}' | sqlite3 '#{DEMO_DB}'`

DBConnection.open(DEMO_DB)

class Chicken < SQLObject
  finalize!
end

class Cow < SQLObject
  finalize!
end

class Farmer < SQLObject
  finalize!
end

class Farm < SQLObject
  finalize!
end

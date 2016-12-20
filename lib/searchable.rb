require_relative 'db_connection'
require_relative 'sql_object'

module Searchable

  def where(params)
    where_line = params.keys.map{|key| "#{key.to_s} = ?"}.join(" AND ")
    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    data.empty? ? data : data.map {|datum| self.new(datum)}
  end

end

class SQLObject
  extend Searchable
end

require_relative 'db_connection'
require_relative 'sql_object'

module Searchable

  def where(search_params)
    if search_params.is_a?(String)
      where_line = search_params
      search_values = []
    elsif search_params.is_a?(Hash)
      where_line = search_params.keys.map{|key| "#{key.to_s} = ?"}.join(" AND ")
      search_values = search_params.values
    end

    data = DBConnection.execute(<<-SQL, *search_values)
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

puts "Import/overwrite neighborhood spatial data? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  puts "Importing spatial data for NYC neighborhoods"
  connection = ActiveRecord::Base.connection()

  # opens ZillowNeighborhoods-NY in shp2pgsql and save to temp table in db
  # see https://medium.com/@praagyajoshi/importing-combining-and-visualising-geospatial-data-in-a-rails-app-e63a01b5931b
  from_neighborhood_shp_sql = `shp2pgsql -c -g geom -W LATIN1 -s 4326 #{Rails.root.join('db', 'shapefiles', 'ZillowNeighborhoods-NY.shp')} neighborhoods_temp`
  # delete existing temp table
  connection.execute "drop table if exists neighborhoods_temp"
  # insert table from shp2pgsql generated sql
  connection.execute from_neighborhood_shp_sql
  # insert into our real table
  connection.execute <<-SQL
    insert into neighborhoods(name, county, geom, regionid, created_at, updated_at)
    select name, county, geom, regionid, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP 
    from neighborhoods_temp
    where city = 'New York'
  SQL
  # drop temp table
  connection.execute "drop table neighborhoods_temp"
end
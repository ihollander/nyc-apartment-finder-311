namespace :make_geojson do

  desc "creates json for NYC neighborhoods"
  task create_neighborhood_json: :environment do
    require 'rgeo/geo_json'

    puts 'Getting data for all the neighborhoods'
    neighborhoods = Neighborhood.all
    puts 'Creating RGeo factory'
    factory = RGeo::GeoJSON::EntityFactory.instance

    neighborhoods.each do |s|
      puts "Creating feature for #{s.name}"
      feature = factory.feature s.geom
      puts 'Generating hash'
      hash = RGeo::GeoJSON.encode feature
      puts 'Writing JSON file'
      File.open("public/geojson/neighborhood_id_#{s.id}.json", 'w') { |file| file.write hash.to_json }
    end
  end

end
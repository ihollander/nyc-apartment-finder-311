require 'csv'

# seed from each file in seeds folder
Dir.glob("#{Rails.root}/db/seeds/*.rb").each do |f| 
  require f 
end 
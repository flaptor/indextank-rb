require "parka/specification"

Parka::Specification.new do |gem|
  gem.name     = "IndexTank"
  gem.version  = IndexTank::VERSION
  gem.summary  = "Ruby Client for the IndexTank API"
  gem.homepage = "http://www.indextank.com"
  gem.authors  = ["Terence Lee", "Santiago Perez"]
  gem.email    = ["terence@heroku.com"]
end


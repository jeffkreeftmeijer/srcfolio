clear_sources

source "http://gemcutter.org"

gem "rails", "2.3.5"

gem "mongo",                        "0.18.0"
gem "mongo_ext",                    "0.18.0"
gem "mongo_mapper",                 "0.6.7"
gem "haml",                         "2.2.16"
gem "jeffkreeftmeijer-delayed_job", "1.7.0", :require_as => 'delayed_job'

only :test, :cucumber do
  gem "rspec-rails",            "1.2.9"
  gem "rspec",                  "1.2.9"
  gem "cucumber",               "0.4.4"
  gem "webrat",                 "0.5.3"
  gem "machinist",              "1.0.6"
  gem "machinist_mongomapper",  "0.9.7", :require_as => 'machinist/mongomapper'
end

disable_system_gems

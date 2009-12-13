# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_srcfolio_session',
  :secret      => 'd80b59f6b0e6f416a2312727937d999049d5c7a05d5edabf72ae2eb1db70693adfba53bc3ca56ab96b47efa9ea5e1790cc93c774faf33f346fbe8e1ffc43ebf5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

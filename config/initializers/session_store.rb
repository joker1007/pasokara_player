# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pasokara_player2_session',
  :secret      => 'bc0cb271a14f793990769b43d9dded52885285e4595328176344564af24de472bcfea10ea55757c937122597c6f7d3cb0407052e1325ecdee528df6bf9b5af2d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

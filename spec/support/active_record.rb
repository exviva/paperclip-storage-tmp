require 'active_record'
ActiveRecord::Base.send(:include, Paperclip::Glue)
require 'fixtures/user'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string   :avatar_file_name
    t.string   :avatar_content_type
    t.integer  :avatar_file_size
    t.datetime :created_at
    t.datetime :updated_at
  end
end

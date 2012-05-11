class User < ActiveRecord::Base
  has_attached_file :avatar, storage: :tmp
end

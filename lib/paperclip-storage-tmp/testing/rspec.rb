require 'paperclip-storage-tmp'

RSpec.configure do |config|
  config.after { Paperclip::Storage::Tmp.clear }
end

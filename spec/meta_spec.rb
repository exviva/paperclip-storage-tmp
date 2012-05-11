require 'spec_helper'

describe 'spec_helper' do
  it 'successfully connects to an in-memory database' do
    User.connection_config[:adapter].should eq('sqlite3')
    User.connection_config[:database].should eq(':memory:')
    User.create!
    User.count.should eq(1)
  end

  it 'rolls back between examples' do
    User.count.should eq(0)
  end

  it 'defines Rails.root' do
    Rails.root.should eq(File.expand_path('../..', __FILE__))
  end
end

describe User do
  it 'is an active record' do
    User.new.should be_an(ActiveRecord::Base)
  end

  it 'has an avatar' do
    User.new.avatar.should be_a(Paperclip::Attachment)
  end
end

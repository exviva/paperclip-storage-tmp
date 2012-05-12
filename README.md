# paperclip-storage-tmp

[![Build Status](https://secure.travis-ci.org/exviva/paperclip-storage-tmp.png?branch=master)](http://travis-ci.org/exviva/paperclip-storage-tmp)

This gem allows you to configure Paperclip 2.x to use your temporary directory to store the attachments. The attachments are deleted as soon as your Ruby process exits, or whenever you ask the gem to delete them (e.g. after every test), ensuring isolated state for each test.

Thanks to this gem your `public/system` directory is no longer cluttered with attachments dangling in there after your test suite has finished running.

It also prevents the attachments created by tests from conflicting with attachments uploaded in development. Storing the images using the default, `filesystem` storage both in development and test environments may lead to false positives and other unexpected behaviour in your tests.

As an example, imagine you upload an avatar in development. It will probably land in a path similar to `public/system/users/123/avatars/original/hey_mom_its_me.png` (assuming the user's ID is 123). If you feed your application with some kind of fixtures, you probably have hundreds of such files. Now imagine you also have the following test:

    describe User do
      it 'assigns a default avatar' do
        user = User.new

        # This method is supposed to assign a default
        # avatar to the user (called "hey_mom_its_me.png"),
        # and save the record
        user.assign_default_avatar!

        # Yikes! False positive alert!
        user.avatar.should be_present
      end
    end

In the test above, `user.avatar.present?` will check if a file `public/system/users/:id/avatars/original/hey_mom_its_me.jpg` exists. That file could as well have been uploaded in development, and even if your method `assign_default_avatar!` is not doing what you expect it to, your test is still passing.

Just like you wouldn't want to use the same database in development and test, you probably don't want to use the same storage directory (which also is a kind of a database).

## Compatibility with Paperclip versions

Please note that this gem has been written with Paperclip 2.x in mind (extracted from and battle-tested in an application dependent on Paperclip 2.4.0). The gemspec declares a rather loose dependency on Paperclip of '~> 2.0', so make sure the gem is behaving as expected. Since it's supposed to be used only in test environment, it shouldn't be harmful to just give it a try. If you confirm that it's working for the version of Paperclip you're using, let me know.

Any pull requests increasing compatibility with other versions welcome!

## Installation

Add this line to your application's Gemfile:

    gem 'paperclip-storage-tmp', group: 'test'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-storage-tmp

## Usage

### Configuring Paperclip to use the temporary storage

To use the tmp storage, simply provide the `:storage` option with the value of `:tmp`, e.g.:

    class User < ActiveRecord::Base
      has_attached_file :avatar, storage: :tmp
    end

Unless you're drunk, you probably want to do this conditionally:

    class User < ActiveRecord::Base
      has_attached_file :avatar, storage: (Rails.env.test? ? :tmp : :filesystem)
    end

Or use some kind of environment-aware config parameter:

    class User < ActiveRecord::Base
      has_attached_file :avatar, storage: MyApp.config.paperclip.storage
    end

If you want to configure this option globally for all attachments, use an initializer:

    # in config/initializers/paperclip.rb
    Paperclip::Attachment.default_options[:storage] = MyApp.config.paperclip.storage

### Configuring your tests to delete the attachments after every test

The most important part is actually "rolling back the filesystem" after every test, so that the next test will run with isolated state. That's where the `Paperclip::Storage::Tmp.clear` method comes in handy. Call this method in the `teardown`/`after` block of your test framework. Here's an example for `RSpec`:

    # in spec/spec_helper.rb
    RSpec.configure do |config|
      config.after { Paperclip::Storage::Tmp.clear }
    end

Or, just use the provided one-line testing helpers for RSpec and Cucumber, which add the necessary after hooks for you:

    # in spec/spec_helper.rb
    require 'paperclip-storage-tmp/testing/rspec'

    # in features/support/env.rb
    require 'paperclip-storage-tmp/testing/cucumber'

## Caveats

Beware that the file name assigned to the model attribute (`<attachment>_file_name`) is different than the name of the assigned/uploaded file (it's the name of the temporary file - a unique string).

Also, Paperclip doesn't know that the file doesn't physically exist in `public/system`, so you can't use `Attachment#path` to access the physical file. You can use `attachment.to_file.path` to find the actual location of the attachment on disk.

Here are a couple of specs, which expose the expected behaviour of this gem. The specs markes with `# FAIL` expose the caveats:

    describe User do
      describe 'avatar' do
        let(:user) { User.create!(avatar: File.new('spec/fixtures/hey_mom_its_me.png')) }
        subject { user.avatar }

        it { should exist }
        its(:content_type) { should eq('image/png') }
        its(:original_filename) { should eq('hey_mom_its_me.png') }

        its(:path) { should eq(Rails.root + "/public/system/avatars/1/original/hey_mom_its_me.png") }
        its(:to_file) { should be_a(File) }

        it 'is actually stored in /tmp' do
          File.exists?(subject.path).should be_false # FAIL
          subject.to_file.path.should match(%r{^/tmp/})
        end

        it 'copies the assigned file' do
          File.read(subject.to_file).should eq(File.read(avatar_file))
        end

        it 'stores the file in an imagemagick-friendly way' do
          geometry = Paperclip::Geometry.from_file(subject.to_file)
          geometry.width.should eq(256)
          geometry.height.should eq(256)
        end

        it 'stores the file attributes in the model' do
          user.avatar_file_name.should eq('hey_mom_its_me.png')
          user.avatar_content_type.should eq('image/png')
          user.avatar_file_size.should eq(File.size(avatar_file))
        end

        it 'can handle assignment from File' do
          new_user = User.new(avatar: avatar_file)
          new_user.avatar_file_name.should eq('hey_mom_its_me.png')
        end

        it 'can persist assignment from File' do
          new_user = User.create!(avatar: avatar_file)
          new_user.reload.avatar_file_name.should eq('hey_mom_its_me.png')
        end

        # :(
        it 'cannot handle assignment from Paperclip::Attachment' do
          new_user = User.new(avatar: subject)
          new_user.avatar_file_name.should_not eq('hey_mom_its_me.png') # FAIL
        end
      end
    end

## Contributing

In development, the Gemfile points to a version of Paperclip from `vendor/paperclip`, so make sure you have a clone of Paperclip there (e.g. `git clone git://github.com/thoughtbot/paperclip vendor`). You can checkout any version you want to test against.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

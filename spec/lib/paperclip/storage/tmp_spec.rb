require 'spec_helper'

describe Paperclip::Storage::Tmp do
  after { Paperclip::Storage::Tmp.clear }

  let(:avatar_file) { File.new('spec/fixtures/hey_mom_its_me.png') }

  [proc { user.avatar }, proc { user.reload.avatar }].each do |subject_proc|
    describe 'assigning an attachment' do
      let(:user) { User.create!(avatar: avatar_file) }
      subject(&subject_proc)

      it { should exist }
      its(:content_type) { should eq('image/png') }
      its(:original_filename) { should eq('hey_mom_its_me.png') }

      its(:path) { should eq(Rails.root + "/public/system/avatars/1/original/hey_mom_its_me.png") }
      its(:to_file) { should be_a(File) }

      it 'is actually stored in /tmp' do
        File.exists?(subject.path).should be_false
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

      it 'can handle assignment from Paperclip::Attachment' do
        new_user = User.new(avatar: subject)
        new_user.avatar_file_name.should eq('hey_mom_its_me.png')
      end
    end

    describe 'not assigning an attachment' do
      let(:user) { User.create! }
      subject(&subject_proc)

      it { should_not exist }
      its(:content_type) { should be_nil }
      its(:original_filename) { should be_nil }
      its(:path) { should be_nil }
      its(:to_file) { should be_nil }
    end
  end

  describe 'destroying an attachment' do
    let(:user) { User.create!(avatar: avatar_file) }
    subject do
      @path_before_destroy = user.avatar.to_file.path
      user.destroy

      user.avatar
    end

    it { should_not exist }

    it 'should be deleted from the filesystem' do
      subject
      File.exists?(@path_before_destroy).should be_false
    end
  end

  describe 'clear' do
    let(:user) { User.create!(avatar: avatar_file) }
    subject { Paperclip::Storage::Tmp.clear }

    it 'deletes files' do
      path = user.avatar.to_file.path
      subject
      File.exists?(path).should be_false
    end

    it 'deletes the files from virtual fs' do
      user.avatar.should exist
      subject
      user.avatar.should_not exist
    end
  end
end

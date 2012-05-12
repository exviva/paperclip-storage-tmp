## 0.0.2 (2012-05-12):

* Provide one-line testing helpers for RSpec and Cucumber;
  they require the gem and add after hooks which clear the
  tmp storage

## 0.0.1 (2012-05-11):

* Implement `Paperclip::Storage::Tmp.clear` which clears all
  attachments from the filesystem (and from the "virtual" filesystem)
* Provide a `:tmp` storage option for Paperclip attachments

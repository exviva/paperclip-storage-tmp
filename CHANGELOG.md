## Not released yet:

* (no changes)

## 0.0.4 (2012-06-15):

* Ruby 1.8 compatability: use `Tempfile#path` when opening new file
  instead passing `Tempfile` directly (mikz)
* Rewind the file queued for write before returning it (exviva)
* Unlink the file **and** close the file descriptor when clearing
  the attachments (exviva)

## 0.0.3 (2012-05-15):

* Depend on Paperclip `>= 2.4.2`, which properly handles
  `<attachment>_file_name` assignment from `Paperclip::Attachment` (exviva)

## 0.0.2 (2012-05-12):

* Provide one-line testing helpers for RSpec and Cucumber;
  they require the gem and add after hooks which clear the
  tmp storage (exviva)

## 0.0.1 (2012-05-11):

* Implement `Paperclip::Storage::Tmp.clear` which clears all
  attachments from the filesystem (and from the "virtual" filesystem) (exviva)
* Provide a `:tmp` storage option for Paperclip attachments (exviva)

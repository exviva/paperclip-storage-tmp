module Paperclip
  module Storage
    module Tmp
      def self.fs
        @fs ||= {}
      end

      # Deletes the temporary files and releases references to them
      def self.clear
        fs.each_value {|f| f.close! }
        @fs = nil
      end

      def exists?(style_name = default_style)
        Tmp.fs.key?(path(style_name))
      end

      def to_file(style_name = default_style)
        if @queued_for_write[style_name]
          @queued_for_write[style_name].rewind
          @queued_for_write[style_name]
        elsif exists?(style_name)
          File.new(Tmp.fs[path(style_name)], 'rb')
        end
      end

      def flush_writes
        @queued_for_write.each do |style_name, file|
          Tmp.fs[path(style_name)] = to_tempfile(file)
        end

        after_flush_writes
        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          if file = Tmp.fs.delete(path)
            file.close!
          end
        end

        @queued_for_delete = []
      end
    end
  end
end

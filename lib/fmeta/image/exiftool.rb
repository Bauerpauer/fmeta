require "strscan"
require "tempfile"
require "shellwords"
require "date"

class Fmeta::Image
  
  module Exiftool

    MINIMUM_EXIFTOOL_VERSION = '7.86'
  
    ##
    # Responsible for the execution of exiftool commands
    ##
    class Shell
      
      class ExecutionError < StandardError
        def initialize(command, status, error_messages)
          super("Exiftool Command failed: #{command}\nExit Status: #{status}\nMessages: #{error_messages}")
        end
      end
      
      ##
      # Execute an exiftool command, return stdout, or raise an ExecutionError if the exitstatus
      # was not 0
      ##
      def self.run(command)
        error_file = Tempfile.new('fmeta')

        output = `#{command} 2>#{Shellwords.escape(error_file.path)}`
        if (status = $?) && status.exitstatus != 0
          error_messages = nil
      
          if File.file?(error_file.path)
            error_messages = File.read(error_file.path) 
            FileUtils.rm(error_file.path)
          end
      
          raise ExecutionError.new(command, status.exitstatus, error_messages)
        end

        FileUtils.rm(error_file.path) if File.file?(error_file.path)

        output
      end
      
    end

    ##
    # Ensure that the proper version of exiftool is installed
    ##
    def self.verify_dependencies
      if (version_string = `exiftool -ver`.strip) =~ /(\d\.?)+/
        self.const_set(:INSTALLED_EXIFTOOL_VERSION, version_string)

        if self::INSTALLED_EXIFTOOL_VERSION.to_f < self::MINIMUM_EXIFTOOL_VERSION.to_f
          warn "You need to install a more recent version of exiftool. You have #{self::INSTALLED_EXIFTOOL_VERSION}, but the minimum requirement is #{self::MINIMUM_EXIFTOOL_VERSION}: http://www.sno.phy.queensu.ca/~phil/exiftool/"
          return false
        end
      else
        warn "You need to install exiftool: http://www.sno.phy.queensu.ca/~phil/exiftool/"
        return false
      end
    
      true
    end
  
    ##
    # Reads image metadata and returns instances of Fmeta::Image::Tag
    ##
    class Reader

      EXIFTOOL_COMMAND = %q{exiftool -q -q -s -t -G}
      DATE_FORMAT_REGEXP = /^((\d{4}):(\d\d):(\d\d) (\d\d):(\d\d):(\d\d))($|(\+|\-)\d\d:\d\d)/
  
      def initialize(path)
        @path = path
      end
      
      def read_all
        read_tags
      end

      private

      def read_tags
        command = "#{EXIFTOOL_COMMAND} #{Shellwords.escape(@path)}"

        output = ::Fmeta::Image::Exiftool::Shell.run(command)
        
        tags = []
        scanner = StringScanner.new(output)

        until scanner.eos?
          category = scanner.scan_until(/\t/)[0..-2]
          name = scanner.scan_until(/\t/)[0..-2]
          value = parse_tag_value(scanner.scan_until(/\n/)[0..-2])

          tags << ::Fmeta::Image::Tag.new(category, name, value)
        end
    
        tags
      end

      def parse_tag_value(tag_value_string)
        if match = DATE_FORMAT_REGEXP.match(tag_value_string)
          components = match.to_a[2..7].map { |c| c.to_i }
          components << match[-2]

          DateTime.civil(*components)
        else
          tag_value_string
        end
      end

    end
    
    ##
    # Writes tag values back to an image
    ##
    class Writer
      
      class WriteError < StandardError
        def initialize(path)
          super("Couldn't find temp file #{path} after successful execution.")
        end
      end
      
      EXIFTOOL_COMMAND = %q{exiftool}
      
      def initialize(path)
        @path = path
      end
      
      def write(tags)
        tempfile = Tempfile.new('fmeta')
        FileUtils.cp(@path, tempfile.path)
        
        tag_parameters = tags.map do |tag|
          "-#{tag.category ? "#{tag.category}:" : nil}#{tag.name}=#{Shellwords.escape(exiftool_writable_tag_value(tag))}"
        end.join(' ')

        error_file = Tempfile.new('fmeta')
        command = "#{EXIFTOOL_COMMAND} #{tag_parameters} #{Shellwords.escape(tempfile.path)} 2>#{Shellwords.escape(error_file.path)}"
        
        begin
          ::Fmeta::Image::Exiftool::Shell.run(command)
        rescue
          FileUtils.rm(tempfile.path) if File.file?(tempfile.path)
          raise
        end

        if File.file?(tempfile.path)
          FileUtils.mv(tempfile.path, @path)
        else
          raise Exiftool::Writer::WriteError.new(tempfile.path)
        end
        
        true
      end
      
      private
      
      ##
      # Converts a tag's value into something that exiftool can accept on the command line.
      ##
      def exiftool_writable_tag_value(tag)
        case tag.value
        when DateTime
          tag.value.strftime('%Y:%m:%d %H:%M:%S%Z')
        else
          tag.value.to_s
        end
      end

    end

  end
  
end
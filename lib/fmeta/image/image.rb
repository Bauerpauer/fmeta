require "set"

module Fmeta
  
  class Image

    def initialize(path)
      @path = path
      @reader = Exiftool::Reader.new(@path)
      @tags = Set.new
    end
    
    def tags
      load_all_tags

      @tags
    end
    
    ##
    # Removes metadata from any tag that doesn't match one of the exceptions.
    ##
    def clear(exceptions = [])
      tags.each do |tag|
        if exceptions.none? { |exception| tag =~ exception }
          tag.value = nil
        end
      end
    end
    
    def [](key)
      load_all_tags

      tag = load_tag(key)
      tag ? tag.value : nil
    end
    
    def []=(key, value)
      tag = load_tag(key)
      tag.value = value
    end

    def save
      return true unless @tags.any? { |t| t.dirty? }

      save_meta

      true
    end

    private
    
    def load_all_tags
      return if @all_tags_loaded
      # Preload all available tags, only adding new keys
      @reader.read_all.each { |tag| @tags.add?(tag) }
      
      @all_tags_loaded = true
    end

    def save_meta
      writer = Exiftool::Writer.new(@path)
      
      dirty_tags = @tags.select { |t| t.dirty? }
      writer.write(dirty_tags)
      dirty_tags.each { |tag| tag.commit }
    end

    def load_tag(key)
      category, key = Tag::split(key)

      tag = if category        
        tags.detect { |t| t.category == category && t.name == key }
      else
        tags.detect { |t| t.name == key }
      end

      if tag.nil?
        tag = Tag.new(category, key, nil)
        # Ensure that the new tag is dirty
        # tag.value = nil

        @tags << tag
      end

      tag
    end

  end

end
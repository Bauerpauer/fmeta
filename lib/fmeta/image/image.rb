require "set"

module Fmeta
  
  class Image

    def initialize(path)
      @path = path
      @reader = Exiftool::Reader.new(@path)
      @tags = Set.new
      @all_tags_loaded = false
    end
    
    def load_all_tags
      # Preload all available tags, only adding new keys
      @reader.read_all.each { |tag| @tags.add?(tag) }
      
      @all_tags_loaded = true
    end
    
    def [](key)
      load_all_tags unless @all_tags_loaded

      tag = load_tag(key)
      tag ? tag.value : nil
    end
    
    def []=(key, value)
      tag = load_tag(key)
      tag.value = value
    end

    def save
      return true unless @tags.is_a?(Set) && @tags.any? { |t| t.dirty? }

      save_meta
    end

    private
    
    def save_meta
      Exiftool::Writer.new(@path).write(@tags.select { |t| t.dirty? })
    end
    
    def load_tag(key)
      key =~ /((.*):)?(.*)/
      category = $2
      key = $3

      tag = if category        
        @tags.detect { |t| t.category == category && t.name == key }
      else
        @tags.detect { |t| t.name == key }
      end

      if tag.nil?
        tag = Tag.new(category, key, nil)
        # Ensure that the new tag is dirty
        tag.value = nil

        @tags << tag
      end

      tag
    end

  end

end
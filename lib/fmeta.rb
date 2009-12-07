require "fmeta/version"

require "fmeta/shellwords"

require "fmeta/image/image"
require "fmeta/image/tag"
require "fmeta/image/exiftool"

exit(1) unless Fmeta::Image::Exiftool.verify_dependencies
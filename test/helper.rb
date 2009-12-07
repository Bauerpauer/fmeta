require "pathname"
require "test/unit"

$LOAD_PATH.unshift(Pathname(__FILE__).dirname.parent + "lib")

require "fmeta"

SAMPLE_PATH = (Pathname(__FILE__).dirname + "media/sample.jpg").to_s
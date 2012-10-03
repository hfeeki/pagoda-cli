require 'bundler/setup'
# require 'fakefs'
require 'pagoda/cli/helpers'
require 'pagoda/cli/helpers/base'
require 'pagoda/cli/helpers/app'
require 'pagoda/cli/helpers/key'
require 'pagoda/cli/helpers/tunnel'

require 'pagoda/cli/core_ext'

def silently(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end
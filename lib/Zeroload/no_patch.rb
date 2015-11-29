module Zeroload
  if defined?(Patch)
    raise "Zeroload has been required before zeroload/no_patch"
  else
    Patch = false
  end
end

require "Zeroload"

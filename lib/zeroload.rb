require 'zeroload/version'
require 'zeroload/auto'

# Zeroload
# Automatically autoload all constants for a module. This requires a change from
# the current convention of putting class Foo::BarBaz into foo/barbaz.rb (or
# foo/bar_baz.rb in rails) to using Foo/BarBaz.rb instead.
module Zeroload
  def self.module(mod, directory=nil)
    directory ||= caller_locations.first.absolute_path.sub(/\.[^.]*\z/, "".freeze)

    Dir.glob("#{directory}/*.{rb,so,bundle,dll}") do |path|
      name = File.basename(path)
      if /\A[A-Z]/ =~ name
        name.sub!(/\.[^.]*\z/, "".freeze)
        warn "#{mod} autoloads #{mod}::#{name} from #{path}" if $VERBOSE
        mod.autoload :"#{name}", path
      end
    end
  end
end

require 'zeroload/version'
require 'zeroload/auto'

# Zeroload
# Automatically autoload all constants for a module. This requires a change from
# the current convention of putting class Foo::BarBaz into foo/barbaz.rb (or
# foo/bar_baz.rb in rails) to using Foo/BarBaz.rb instead.
module Zeroload
  @registry = {}
  Name      = Module.instance_method(:name)

  class << self
    attr_reader :registry
  end

  begin
    Object.const_get("Zeroload::Name") # test whether this ruby supports nested constant lookup
  rescue

    # Zeroload.const_get
    #
    # Backport ruby 2.0's deep Module#const_get (<= 1.9 fails at lookups for
    # nested constants).
    def self.const_get(name)
      raise NameError, "wrong constant name #{name}" unless name =~ /[A-Z]\w*(?:::[A-Z]\w*)*/
      eval name
    end
  else
    define_singleton_method(:const_get, Module.instance_method(:const_get))
  end

  # Register a module to be zero-loaded.  
  # Use Module#zeroload! instead.
  #
  # @param [Module, Class] mod
  #   The module which should be autoloaded.
  # @param [String, nil] directory
  #   The directory in which to search for nested constants.
  #
  # @return mod
  #   Returns the module which is zeroloaded
  def self.module(mod, directory=nil)
    directory ||= caller_locations.first.absolute_path.sub(/\.[^.]*\z/, "".freeze)
    mod_name    = Name.bind(mod).call.to_sym rescue nil # some modules don't have a name
    @registry[mod_name] ||= {} if mod_name

    Dir.glob("#{directory}/*.{rb,so,bundle,dll}") do |path|
      name = File.basename(path)
      if /\A[A-Z]/ =~ name
        name = :"#{name.sub(/\.[^.]*\z/, "".freeze)}"

        warn "#{mod} autoloads #{mod}::#{name} from #{path}" if $VERBOSE

        @registry[mod_name][name] = path if mod_name
        mod.autoload name, path
      end
    end

    mod
  end

  # Preload all zeroloaded constants for all or a given module.
  #
  # @param [Module, Class] mod
  #   The module whose autoloaded constants should be preloaded
  # @param [true, false] recursive
  #   Whether the constants should be recursively loaded, or only the current
  #   level
  #
  # @return nil
  def self.preload!(mod=nil, recursive=true)
    if mod
      mod_name = Name.bind(mod).call.to_sym rescue nil # some modules don't have a name
      preload  = @registry[mod_name]

      if preload
        preload.each_key do |name|
          loaded = mod.const_get(name)
          preload!(loaded, true) if recursive
        end
      end
    else
      @registry.dup.each do |mod_name, nesting|
        loaded = Zeroload.const_get(mod_name.to_s)
        Zeroload.preload!(loaded, true)
      end
    end

    nil
  end
end

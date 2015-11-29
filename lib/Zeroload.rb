require "Zeroload/Version"

# Zeroload
# Automatically autoload all constants for a module. This requires a change from
# the current convention of putting class Foo::BarBaz into foo/barbaz.rb (or
# foo/bar_baz.rb in rails) to using Foo/BarBaz.rb instead.
#
# @example Usage
#     require "Zeroload"
#
#     class Foo
#        zeroload! # calls Zeroload.module(Foo)
#     end
#     Foo::Bar # will now load Foo/Bar.rb
#
module Zeroload

  # Controls whether Module is automatically patched or not.
  # Zeroload/no_patch.rb sets it to false. It is not advised to use this
  # option, since using zeroload is viral.
  Patch = true unless defined?(Patch)

  # All registered autoloads. A nested hash of the structure:  
  # `{NestedModuleName: {UnnestedModuleName => path}`  
  # e.g. `{"Foo::Bar" => {"Baz" => "/absolute/path/to/Foo/Bar/Baz.rb"}}`
  Registry = {}

  # Module#name as UnboundMethod
  Name     = Module.instance_method(:name)

  # Patches the Module class, adding Module#zeroload!, which invokes
  # 
  # @return self
  def self.patch!
    ::Module.class_eval do
      def zeroload!(directory=nil, *args)
        directory ||= caller_locations.first.absolute_path.sub(/\.[^.]*\z/, "")

        Zeroload.module(self, directory, *args)
      end
    end

    self
  end
  patch! if Patch

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
    mod_name    = Name.bind(mod).call rescue nil # some modules don't have a name
    Registry[mod_name] ||= {} if mod_name

    Dir.glob("#{directory}/*.{rb,so,bundle,dll}") do |path|
      name = File.basename(path)
      if /\A[A-Z]/ =~ name
        name = :"#{name.sub(/\.[^.]*\z/, "".freeze)}"

        warn "#{mod} autoloads #{mod}::#{name} from #{path}" if $VERBOSE

        Registry[mod_name][name] = path if mod_name
        mod.autoload name, path
      end
    end

    mod
  end

  # Preload all zeroloaded constants for all or a given module.
  #
  # NOTE! Module#constants properly lists all constants, even if the file
  # has not yet been loaded.
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
      nested_mod_name = Name.bind(mod).call rescue nil # some modules don't have a name
      preload         = Registry[nested_mod_name]

      if preload
        preload.each_key do |name|
          loaded = mod.const_get(name)
          preload!(loaded, true) if recursive
        end
      end
    else
      Registry.dup.each do |nested_mod_name, zeroloaded|
        loaded = Object.const_get(nested_mod_name) # Object.const_get does not like Symbols for nested modules.
        Zeroload.preload!(loaded, true)
      end
    end

    nil
  end
end

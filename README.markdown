README
======


Summary
-------

Automatically autoload all constants for a module.  
Reduces your requires to one line per file, plus external dependencies.  
Enables requiring always only the precise file holding the constant you
depend on (or top level if you depend on many).


Installation
------------

`gem install zeroload`


Usage
-----

Map your constants to filenames by replacing :: with /. For example, the
constant Foo::BarBaz should be defined in file lib/Foo/BarBaz.rb. Note that
the case matters! Each file should require the nesting namespace. That is,
Foo/BarBaz.rb should require "Foo". All modules & classes always use
zeroload.

### Example

Given the files

* lib/Foo.rb
* lib/Foo/Bar.rb

The contents of lib/Foo.rb is:

    require "zeroload"

    module Foo
      zeroload!

      # Code of Foo
    end

And the contents of lib/Foo/bar.rb is:

    require "Foo"

    module Foo
      class Bar
        zeroload! # only necessary if there's stuff nested below 

        # Code of Foo::Bar
      end
    end



Description
-----------

Automatically autoload all constants for a module. This requires a change from
the current convention of putting class Foo::BarBaz into foo/barbaz.rb (or
foo/bar_baz.rb in rails) to using Foo/BarBaz.rb instead.


Caveats
-------

* **Q:** But didn't have Kernel#autoload problems with multi-threading?  
* **A:** Yes, it did. They've since been resolved:
  * [see bug 921](https://bugs.ruby-lang.org/issues/921)
  * [see Revision 33078](https://bugs.ruby-lang.org/projects/ruby-trunk/repository/revisions/33078)
* **Q:** But isn't Kernel#autoload deprecated?
* **A:** Sadly, the state on this is not entirely clear. But it seems it is no longer deprecated.
* **Q:** But with autoloaded constants, Module#constants will not report all constants.
* **A:** That is not correct. Autoloaded (but not yet loaded) constants show up with
  Module#constants. But you can also use Zeroconf.preload! to load all constants at once.

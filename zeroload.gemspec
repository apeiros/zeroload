Gem::Specification.new do |s|
  s.name                      = "zeroload"
  s.version                   = "0.0.2"
  s.authors                   = "Stefan Rusterholz"
  s.email                     = "stefan.rusterholz@gmail.com"
  s.homepage                  = "https://github.com/apeiros/jacob"
  s.license                   = "BSD 2-Clause"

  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    Automatically autoload all constants for a module. This requires a change from
    the current convention of putting class Foo::BarBaz into foo/barbaz.rb (or
    foo/bar_baz.rb in rails) to using Foo/BarBaz.rb instead.
  DESCRIPTION
  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Automatically autoload all constants for a module.
  SUMMARY

  s.required_ruby_version     = ">= 2.1.0" # TODO: figure out, when autoload became thread-safe
  s.files                     =
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    Dir["*.gemspec"] +
    %w[
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    s.executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
  end
end

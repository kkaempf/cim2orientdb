# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cim2orientdb/version"

Gem::Specification.new do |s|
  s.name        = "cim2orientdb"
  s.version     = CIM2OrientDB::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = "https://github.com/kkaempf/cim2orientdb"
  s.summary     = %q{Map CIM classes to OrientDB classes}
  s.description = %q{Map CIM classes to OrientDB classes.}

  s.rubyforge_project = "cim2orientdb"

  s.files         = `git ls-files`.split("\n")
  s.files.reject! { |fn| fn == '.gitignore' }
  s.extra_rdoc_files    = Dir['README.md', 'LICENSE']
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

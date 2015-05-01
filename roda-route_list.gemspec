spec = Gem::Specification.new do |s|
  s.name = 'roda-route_list'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'roda-route_list: List routes when using Roda', '--main', 'README.rdoc']
  s.license = "MIT"
  s.summary = "List routes when using Roda"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://github.com/jeremyevans/roda-route_list"
  s.files = %w(MIT-LICENSE CHANGELOG README.rdoc Rakefile) + Dir["{spec,lib}/**/*.rb"]
  s.executables << 'roda-parse_routes'
  s.description = <<END
Roda, like other routing tree web frameworks, doesn't have the ability
to introspect routes.  roda-route_list offers a way to specify a json
file containing the route metadata, which the route_list plugin will
read.  It also offers a roda-parse_routes binary that can parse routes
out of roda app files, if those app files contain comments specifying
the routes.
END
  s.required_ruby_version = ">= 1.8.7"
  s.add_dependency "roda"
  s.add_development_dependency "minitest"
end

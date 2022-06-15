require "rake"
require "rake/clean"

CLEAN.include ["rdoc", "roda-route_list-*.gem"]

desc "Build roda-route_list gem"
task :package=>[:clean] do |p|
  sh %{#{FileUtils::RUBY} -S gem build roda-route_list.gemspec}
end

### Specs

desc "Run all specs"
task :spec do |p|
  ENV['RUBY'] = FileUtils::RUBY
  sh %{#{FileUtils::RUBY} #{"-w" if RUBY_VERSION >= '3'} spec/roda-route_list_spec.rb }
end
task :default=>:spec


desc "Run tests with coverage"
task :spec_cov do
  ENV['COVERAGE'] = '1'
  sh "#{FileUtils::RUBY} spec/roda-route_list_spec.rb"
end

### RDoc

RDOC_DEFAULT_OPTS = ["--quiet", "--line-numbers", "--inline-source", '--title', 'roda-route_list: List routes when using Roda']

begin
  gem 'hanna-nouveau'
  RDOC_DEFAULT_OPTS.concat(['-f', 'hanna'])
rescue Gem::LoadError
end

require "rdoc/task"

RDOC_OPTS = RDOC_DEFAULT_OPTS + ['--main', 'README.rdoc']

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end

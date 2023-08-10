require "rake/clean"

CLEAN.include ["rdoc", "roda-route_list-*.gem", "coverage"]

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

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'roda-route_list: List routes when using Roda', '--main', 'README.rdoc']

  begin
    gem 'hanna'
    rdoc.options += ['-f', 'hanna']
  rescue Gem::LoadError
  end

  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end

require 'roda'
require 'json'
require 'minitest/autorun'

describe 'roda-route_list plugin' do
  def req(path='/', env={})
    if path.is_a?(Hash)
      env = path
    else
      env['PATH_INFO'] = path
    end

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/", "SCRIPT_NAME" => ""}.merge(env)
    @app.call(env)
  end
  
  def body(path='/', env={})
    s = ''
    b = req(path, env)[2]
    b.each{|x| s << x}
    b.close if b.respond_to?(:close)
    s
  end

  before do 
    @app = Class.new(Roda)
    @app.plugin :route_list, :file=>'spec/routes.json'
    @app.route do |r|
      named_route(env['PATH_INFO'].to_sym)
    end
    @app
  end

  after do
    File.delete('routes.json') if File.exist?('routes.json')
  end

  it "should correctly parse the routes from the json file" do
    @app.route_list.must_equal [
      {:path=>'/foo'},
      {:path=>'/foo/bar', :name=>:bar},
      {:path=>'/foo/baz', :methods=>[:GET]},
      {:path=>'/foo/baz/quux/:quux_id', :name=>:quux, :methods=>[:GET, :POST]},
    ]
  end

  it "should respect :root option when parsing json file" do
    @app = Class.new(Roda)
    @app.opts[:root] = 'spec'
    @app.plugin :route_list, :file=>'routes2.json'
    @app.route_list.must_equal [{:path=>'/foo'}]
  end

  it ".named_route should return path for route" do
    @app.named_route(:bar).must_equal '/foo/bar'
    @app.named_route(:quux).must_equal '/foo/baz/quux/:quux_id'
  end

  it ".named_route should return path for route when given a values hash" do
    @app.named_route(:quux, :quux_id=>3).must_equal '/foo/baz/quux/3'
  end

  it ".named_route should return path for route when given a values array" do
    @app.named_route(:quux, [3]).must_equal '/foo/baz/quux/3'
  end

  it ".named_route should raise RodaError if there is no matching route" do
    proc{@app.named_route(:foo)}.must_raise(Roda::RodaError)
  end

  it ".named_route should raise RodaError if there is no matching value when using a values hash" do
    proc{@app.named_route(:quux, {})}.must_raise(Roda::RodaError)
  end

  it ".named_route should raise RodaError if there is no matching value when using a values array" do
    proc{@app.named_route(:quux, [])}.must_raise(Roda::RodaError)
  end

  it ".named_route should raise RodaError if there are too many values when using a values array" do
    proc{@app.named_route(:quux, [3, 1])}.must_raise(Roda::RodaError)
  end

  it "should allow parsing routes from a separate file" do
    @app.plugin :route_list, :file=>'spec/routes2.json'
    @app.route_list.must_equal [{:path=>'/foo'}]
  end

  it "#named_route should work" do
    body('bar').must_equal '/foo/bar'
  end

  it "#named_route should respect :add_script_name option" do
    @app.opts[:add_script_name] = true
    body('bar').must_equal '/foo/bar'
    body('bar', 'SCRIPT_NAME'=>'/a').must_equal '/a/foo/bar'
  end
end

describe 'roda-route_parser executable' do
  after do
    File.delete "spec/routes-example.json"
  end

  it "should correctly parse the routes" do
    system(ENV['RUBY'] || 'ruby', "bin/roda-parse_routes", "-f", "spec/routes-example.json", "spec/routes.example")
    File.file?("spec/routes-example.json").must_equal true
    JSON.parse(File.read('spec/routes-example.json')).must_equal JSON.parse(File.read('spec/routes.json'))
  end
end

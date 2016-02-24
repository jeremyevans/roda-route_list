require 'json'

class Roda
  module RodaPlugins
    # The route_list plugin reads route information from a json
    # file, and then makes the route metadata available for
    # introspection.  This provides a workaround to the general
    # issue of routing trees being unable to introspect the routes.
    #
    # This plugin assumes that a json file containing the routes
    # metadata has already been created.  The recommended way to
    # create one is to add comments above each route in the Roda
    # app, in one of the following formats:
    #
    #   # route: /path/to/foo
    #   # route: GET /path/to/foo
    #   # route: GET|POST /path/to/foo/:foo_id
    #   # route[route_name]: /path/to/foo
    #   # route[route_name]: GET /path/to/foo
    #   # route[foo]: GET|POST /path/to/foo/:foo_id
    #
    # As you can see, the general style is a comment followed by
    # the word route.  If you want to name the route, you can
    # put the name in brackets.  Then you have a colon.  Optionally
    # after that you can have the method for the route, or multiple
    # methods separated by pipes if the path works with multiple
    # methods.  The end is the path for the route.
    #
    # Assuming you have added the appropriate comments as explained
    # above, you can create the json file using the roda-route_parser
    # executable that came with the roda-route_list gem:
    #
    #   roda-route_parser -f routes.json app.rb
    #
    # Assuming you have the necessary json file created, you can then
    # get route information:
    #
    #   plugin :route_list
    #
    #   # Array of route metadata hashes
    #   route_list # => [{:path=>'/path/to/foo', :methods=>['GET', 'POST']}]
    #
    #   # path for the route with the given name
    #   listed_route(:route_name) # => '/path/to/foo'
    #
    #   # path for the route with the given name, supplying hash for placeholders
    #   listed_route(:foo, :foo_id=>3) # => '/path/to/foo/3'
    #
    #   # path for the route with the given name, supplying array for placeholders
    #   listed_route(:foo, [3]) # => '/path/to/foo/3'
    #
    # The +listed_route+ method is also available at the instance level to make it
    # easier to use inside the route block.
    module RouteList
      # Set the file to load the routes metadata from.  Options:
      # :file :: The JSON file containing the routes metadata (default: 'routes.json')
      def self.configure(app, opts={})
        file = File.expand_path(opts.fetch(:file, 'routes.json'), app.opts[:root])
        app.send(:load_routes, file)
      end

      module ClassMethods
        # Array of route metadata hashes.
        attr_reader :route_list

        # Return the path for the given named route.  If args is not given,
        # this returns the path directly.  If args is a hash, any placeholder
        # values in the path are replaced with the matching values in args.
        # If args is an array, placeholder values are taken from the array
        # in order.
        def listed_route(name, args=nil)
          unless path = @route_list_names[name]
            raise RodaError, "no route exists with the name: #{name.inspect}"
          end

          if args
            if args.is_a?(Hash)
              range = 1..-1
              path = path.gsub(/:[^\/]+/) do |match|
                unless value = args[match[range].to_sym]
                  raise RodaError, "no matching value exists in the hash for named route #{name}: #{match}"
                end
                value
              end
            else
              values = args.dup
              path = path.gsub(/:[^\/]+/) do |match|
                if values.empty?
                  raise RodaError, "not enough placeholder values provided for named route #{name}: #{match}"
                end
                values.shift
              end

              unless values.empty?
                raise RodaError, "too many placeholder values provided for named route #{name}"
              end
            end
          end

          path
        end

        private

        # Load the route metadata from the given json file.
        def load_routes(file)
          @route_list_names = {}

          routes = JSON.parse(File.read(file))
          @route_list = routes.map do |r|
            path = r['path'].freeze
            route = {:path=>path}

            if methods = r['methods']
              route[:methods] = methods.map(&:to_sym)
            end

            if name = r['name']
              name = name.to_sym
              route[:name] = name.to_sym
              @route_list_names[name] = path
            end

            route.freeze
          end.freeze

          @route_list_names.freeze
          
          nil
        end
      end
      
      module InstanceMethods
        # Calls the app's listed_route method.  If the app's :add_script_name option
        # has been setting, prefixes the resulting path with the script name.
        def listed_route(name, args=nil)
          app = self.class
          path = app.listed_route(name, args)
          path = request.script_name.to_s + path if app.opts[:add_script_name]
          path
        end
      end
    end

    register_plugin(:route_list, RouteList)
  end
end

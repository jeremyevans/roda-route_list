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
    #   named_route(:route_name) # => '/path/to/foo'
    #
    #   # path for the route with the given name, supplying hash for placeholders
    #   named_route(:foo, :foo_id=>3) # => '/path/to/foo/3'
    #
    #   # path for the route with the given name, supplying array for placeholders
    #   named_route(:foo, [3]) # => '/path/to/foo/3'
    #
    # The +named_route+ method is also available at the instance level to make it
    # easier to use inside the route block.
    module RouteList
      module ClassMethods
        def load_routes(file='routes.json')
          @route_list_names = {}

          routes = JSON.parse(File.read(file))
          @route_list = routes.map do |r|
            path = r['path'].freeze
            route = {:path=>path}

            if methods = r['methods']
              route[:methods] = methods.map{|x| x.to_sym}
            end

            if name = r['name']
              name = name.to_sym
              route[:name] = name.to_sym
              @route_list_names[name] = path
            end

            route.freeze
          end

          @route_list.freeze
          @route_list_names.freeze
          
          nil
        end

        # 
        def route_list
          load_routes unless @route_list
          @route_list
        end

        def named_route(name, args=nil)
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
      end
      
      module InstanceMethods
        def named_route(name, args=nil)
          self.class.named_route(name, args)
        end
      end
    end

    register_plugin(:route_list, RouteList)
  end
end

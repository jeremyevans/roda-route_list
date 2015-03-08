class RodaRouteParser
  def self.parse(input)
    new.parse(input)
  end

  def parse(input)
    if input.is_a?(String)
      require 'stringio'
      return parse(StringIO.new(input))
    end

    routes = []
    regexp = /\A\s*#\s*route(?:\[(\w+)\])?:\s+(?:([A-Z|]+)?\s+)?(\S+)\s*\z/
    input.each_line do |line|
      if md = regexp.match(line)
        name, methods, route = md.captures
        route = {'path'=>route}

        if methods
          route['methods'] = methods.split('|').compact
        end

        if name
          route['name'] = name
        end

        routes << route
      end
    end

    routes
  end
end

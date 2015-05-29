require 'byebug'
require 'uri'

module RailsLite
  class Params
    # initialize merges params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})
      hash = {}

      if req.query_string
        hash.merge! parse_www_encoded_form(req.query_string)
      end

      if req.body
        hash.merge! parse_www_encoded_form(req.body)
      end

      @route_params = route_params.merge(hash)
    end

    def [](key)
      @route_params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this returns deeply nested hash:
    #   this argument format:
    #   user[address][street]=main&user[address][zip]=89436
    #   will return this:
    #   { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      hash = {}

      URI::decode_www_form(www_encoded_form).each do |arr|
        hash[arr.first] = arr.last
      end

      deep_hash = {}

      hash.each do |key, value|
        if key.match(/\[/).nil? #key is not an array
          deep_hash[key] = value
        else
          arr = parse_key(key)
          deep_hash[arr[0]] ||= {}
          deep_hash[arr[0]][arr[1]] ||= {}
          deep_hash[arr[0]][arr[1]][arr[2]] = value
        end
      end

      deep_hash
    end

    # this returns an array
    # user[address][street] will return ['user', 'address', 'street']
    def parse_key(key)
      re = /\]\[|\[|\]/
      key.split(re)
    end
  end
end

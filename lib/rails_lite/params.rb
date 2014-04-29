require 'uri'
require 'forwardable'

class Params
  
  #Jeff Magic
  extend Forwardable
  def_delegators :@params, :[], :[]=
  
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @req = req
    @params = {}
    #@params
    parse_query(@req.query_string)
    parse_body(@req.body)
  end
  
  # def [](key)
#     @params[key]
#   end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_query(query_string)
    key_array = parse_key(query_string)
    
    if key_array.nil?
      return {}
    elsif parse_key(query_string).length > 1
      (0..(key_array.length - 1)).each do |i|
        @params[key_array[i]] = {}
      end
    else
      parsed_query = URI.decode_www_form(query_string)
      parsed_query.each do |query_element|  
        @params[query_element.first] = query_element.last
      end
    end
  end
  
  def parse_body(body)
    if body.nil?
      return {}
    else
      parsed_body = URI.decode_www_form(body)
      parsed_body.each do |body_element|  
        @params[body_element.first] = body_element.last
      end
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    all_keys = key.select { |key| key[/\]\[|\[|\]/] }
  end
end

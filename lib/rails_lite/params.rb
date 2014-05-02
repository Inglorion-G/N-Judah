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
    @params = route_params
    #@params
    parse_query(@req.query_string)
    parse_body(@req.body)
  end

  def permit(*keys)
    @permitted.push *keys
  end

  def require(key)
    raise AttributeNotFoundError unless @params.has_key?(key)
    @parms[key]
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
    @params.to_json.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_query(query_string)
    return {} if query_string.nil?
    parsed_query = URI.decode_www_form(query_string)
    nest_hash(parsed_query)
  end
  
  def parse_body(body)
    return {} if body.nil?
    parsed_body = URI.decode_www_form(body)
    nest_hash(parsed_body)
  end
  
  def nest_hash(query_vals)
    query_vals.each do |query|
      key = query.first
      value = query.last
      all_keys = parse_key(key)
        
      if all_keys.length == 1
        @params[key] = value
      else
        base = @params
        all_keys[0...-1].each do |key|
          base[key] ||= {}
          base = base[key]
        end
        base[all_keys.last] = value
      end 
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end

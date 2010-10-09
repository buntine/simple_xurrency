require 'open-uri'
require 'timeout'
require 'crack'

module CurrencyConvertible
  def method_missing(method, *args, &block)
    return _from(method.to_s) if method.to_s.length == 3

    if @original && !(method.to_s =~ /^to_(utc|int|str|ary)/) && method.to_s =~/^to_/ && method.to_s.length == 6
      return _to(method.to_s.gsub('to_',''))
    end

    if @original && !(method.to_s =~ /^(singleton_methods|protected_methods)/) && method.to_s =~/^to_[a-z]{3}_updated_at/ && method.to_s.length == 17
      return _updated_at(method.to_s.slice(3..5))
    end

    super(method,*args,&block)
  end

  private
   
    # Called from first currency metamethod to set the original currency.
    # 
    # 30.eur # => Calls _from and sets @original to 'eur'
    #
    def _from(currency)
      @original = currency
      self
    end

    # Called from last currency metamethod to set the target currency.
    # 
    #   30.eur.to_usd 
    #   # => Calls _to and returns the final value, say 38.08
    #
    def _to(target)
      raise unless @original # Must be called after a _from have set the @original currency

      return 0.0 if self == 0 # Obviously

      original = @original

      amount = self

      result = exchange(original, target, amount.abs)

      result
    end
    
    # Called from first currency metamethod to set the original currency.
    # 
    # 30.eur # => Calls _from and sets @original to 'eur'
    #
    def _updated_at(target)
      result = rate(@original, target)
      
      result[:updated_at]
    end

    # Main method (called by _to) which calls Xurrency strategies
    # and returns a nice result.
    #
    def exchange(original, target, amount = 1)
      if amount > 999_999_999 # Xurrency API does not support numbers bigger than this
        amount = 1
        multiplier = self.abs # Save a multiplier to apply it to the result later
      end

      negative = (self < 0)

      result = rate(original, target)

      result = sprintf("%.4f", result[:rate].to_f*amount*(multiplier || 1)).to_f

      return -(result) if negative
      result
    end

    # Calls Xurrency API to perform the exchange without a specific date (assuming today)
    #
    def rate(original, target)
      if SimpleXurrency.cache_enabled?
        cached_result = SimpleXurrency.cache_get("#{original}_#{target}")

        if !cached_result.nil?
          return cached_result 
        end
      end

      api_url = "http://xurrency.com/api/#{[original, target].join('/')}/1"
      
      api_url << "?key=#{SimpleXurrency.key}" if !SimpleXurrency.key.nil?
      
      uri = URI.parse(api_url)

      retries = 10
      json_response = nil
      begin
        Timeout::timeout(1){
          json_response = uri.open.read || nil # Returns the raw response
        }
      rescue Timeout::Error
        retries -= 1
        retries > 0 ? sleep(0.42) && retry : raise
      end
      
      return nil unless json_response && parsed_response = Crack::JSON.parse(json_response)
      if parsed_response['status'] == 'fail'
        raise parsed_response['message']
      end

      value = Hash.new
      
      value[:rate] = parsed_response['result']['value'].to_f
      value[:updated_at] = parsed_response['result']['updated_at'].to_s
      
      SimpleXurrency.cache_add("#{original}_#{target}", value) if SimpleXurrency.cache_enabled?
      
      value
    end
end
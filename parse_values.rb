def parse_www_encoded_form(www_encoded_form)
  params = {}

  key_values = URI.decode_www_form(www_encoded_form)
  key_values.each do |full_key, value|
    scope = params

    key_seq = parse_key(full_key)
    key_seq.each_with_index do |key, idx|
      if idx + 1 == key_seq.count
        scope[key] = value
      else
        scope[key] ||= {}
        scope = scope[key]
      end
    end
  end

  params
end

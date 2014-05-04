module RouteOverrides

  def polymorphic_url(obj, options={})
    obj.kind_of?(Array) ? url_from_array(obj, options) : url_from_object(obj, options)
  end

  def url_from_object(obj, options)
    inflection = :singular if options[:action] == 'new' || obj.persisted?
    inflection ||= :plural
    args = nil
    if options.present?
      url_options = options.inject({}){|h,pair| h[pair[0]] = pair[1] unless [:action, :routing_type].include?(pair[0]); h}
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    self.send(build_named_route_call(obj, inflection, options), *args)
  end

  def url_from_array(array, options={})
    recipient = array.shift if array.first.kind_of?(ActionDispatch::Routing::RoutesProxy)
    record = convert_to_model(extract_record(array))

    if record.try(:persisted?)
      inflection = :singular
    elsif options[:action_name] == 'new'
      inflection = array.pop && :singular
    else
      inflection = array.pop && :plural
    end

    args = array.select{|arg| ! [String, Symbol].include?(arg.class)}.map{|arg| convert_to_model(arg)}
    if args.present? && options.present?
      url_options = options.inject({}){|h,pair| h[pair[0]] = pair[1] unless [:action, :routing_type].include?(pair[0]); h}
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    (recipient || self).send(build_named_route_call(array, inflection, options), *args)
  end

end
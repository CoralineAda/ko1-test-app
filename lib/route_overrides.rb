module RouteOverrides

  def polymorphic_url(obj, options={})
    obj.kind_of?(Array) ?  url_from_array(obj, options) : url_from_object(obj, options)
  end

  def url_from_object(obj, options)
    inflection = :singular if options[:action] == 'new' || obj.persisted?
    inflection ||= :plural
    args = nil
    if options.present?
      args = temp_args.select{|arg| ! ["String", "Symbol"].include?(arg.class.name) }
      args = args.map{|arg| convert_to_model(arg)}
      url_options = options.except(:action, :routing_type)
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    self.send(build_named_route_call(obj, inflection, options), *args)
  end

  def url_from_array(array, options={})
    recipient = array.shift if array.first.kind_of?(ActionDispatch::Routing::RoutesProxy)
    record = convert_to_model(extract_record(array))

    inflection, temp_args = if record.try(:persisted?)
      [:singular, array]
    elsif
      [:singular, array.pop && array]
    else
      [:plural, array.pop && array]
    end
    args = temp_args.select{|arg| ! ["String", "Symbol"].include?(arg.class.name) }.map{|arg| convert_to_model(arg)}
    if options.present?
      url_options = options.except(:action, :routing_type)
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    named_route = build_named_route_call(array, inflection, options)
    (recipient || self).send(named_route, *args)
  end

end
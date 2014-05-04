module RouteOverrides

  def inflection_with_args(record, args, action_name)
    return :plural, args.pop && args unless record.try(:persisted?)
    return :singular, args.pop && args if action_name.to_s == "new"
    [:singular, args]
  end

  def sanitize_args(args)
    args.delete_if {|arg| arg.kind_of?(Symbol) || arg.kind_of?(String)}
  end

  def polymorphic_url(obj, options={})
    obj.kind_of?(Array) ?  url_from_array(obj, options) : url_from_object(obj, options)
  end

  def url_from_object(obj, options)
    inflection = :singular if options[:action] == 'new' || obj.persisted?
    inflection ||= :plural
    args = nil
    if options.present?
      args = sanitize_args(options).collect! { |a| convert_to_model(a) }
      url_options = options.except(:action, :routing_type)
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    self.send(build_named_route_call(obj, inflection, options), *args)
  end

  def url_from_array(array, options={})
    recipient = array.shift if array.first.kind_of?(ActionDispatch::Routing::RoutesProxy)
    record = convert_to_model(extract_record(array))
    inflection, temp_args = inflection_with_args(record, array, options.fetch(:action, nil))
    args = temp_args.inject([]) do |a, arg|
      a << convert_to_model(arg) unless [Symbol, String].include?(arg.class)
      a
    end
    if options.present?
      url_options = options.except(:action, :routing_type)
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    named_route = build_named_route_call(array, inflection, options)
    (recipient || self).send(named_route, *args)
  end

end
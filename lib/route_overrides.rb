module RouteOverrides

  def extract_params_from(args)
    return self, args unless args.kind_of? Array
    args.compact!
    raise ArgumentError, "Nil location provided. Can't build URI." if args.include? nil
    return [
      (args.first.kind_of?(ActionDispatch::Routing::RoutesProxy) && args.shift || self),
      args
    ]
  end

  def inflection_with_args(action_name, record, args)
    return :plural, args.pop && args unless record.try(:persisted?)
    return :singular, args.pop && args if action_name.to_s == "new"
    return :singular, args unless action_name
    return :singular, args
  end

  def convert_and_extract(subject)
    convert_to_model(extract_record(subject))
  end

  def sanitize_args(args)
    args.delete_if {|arg| arg.kind_of?(Symbol) || arg.kind_of?(String)}
  end

  def polymorphic_url(subject, options={})
    recipient, subject = extract_params_from(subject)
    record = convert_and_extract(subject)
    args = [subject.dup].flatten
    inflection, args = inflection_with_args(options.fetch(:action, nil),record,args)
    args = sanitize_args(args).collect! { |a| convert_to_model(a) }
    url_options = options.except(:action, :routing_type)
    unless url_options.empty?
      args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
    end
    named_route = build_named_route_call(subject, inflection, options)
    recipient.send(named_route, *args)
  end

end
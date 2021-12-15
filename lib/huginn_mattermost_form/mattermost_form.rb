module Agents
  class MattermostForm < Agent
    default_schedule '12h'

    description <<-MD
      Add a Agent description here
    MD

    def default_options
      {
      }
    end

    def validate_options
    end

    def working?
      # Implement me! Maybe one of these next two lines would be a good fit?
      # checked_without_error?
      # received_event_without_error?
    end

    def receive_web_request(request)
      secret = request.path_parameters[:secret]
      return ["Not Authorized", 401] unless secret == interpolated['secret']

      params = request.query_parameters.dup 
      begin
        params.update(request.request_parameters)
      rescue EOFError
      end

      method = request.method_symbol.to_s
      headers = request.headers.each_with_object({}) { |(name, value), hash|
        case name
        when /\AHTTP_([A-Z0-9_]+)\z/
          hash[$1.tr('_','-').gsub(/[^-]+/, &:capitalize)] = value
        end
      }

      verbs = (interpolated['verbs'] || 'post').split(/,/).map { |x| x.strip.downcase }.select { |x| x.present? }
      return ["Please use #{verbs.join('/').uppercase} requests only", 401] unless verbs.include?(method)

      code = (interpolated['code'].presence || 201).to_i

      # Add stuff here to get the pokemon ball

      if interpolated['response_headers'].presence
        [interpolated['response_headers']]


    end

#    def check
#    end

#    def receive(incoming_events)
#    end
  end
end

module Agents
  class MattermostForm < Agent
    include EventHeadersConcern
    include WebRequestConcern

    default_schedule 'never'
    no_bulk_receive!
    cannot_receive_events!
    cannot_be_scheduled!

    description <<-MD
      Add a Agent description here
    MD

    def default_options
      {
        'secret' => 'supersecretstring',
        'post_url' => 'https://mm.example.com/api/v4/actions/dialogs/open',
        'expected_receive_period_in_days' => '31',
        'payload' => {
          'url' => 'https://huginn.example.com/users/1/web_requests/1/supersecretstring',
          'trigger_id' => "{{ trigger_id }}",
          'dialog' => {
            'callback_id' => "{{ context.send_from }}",
            'title' => "Send Reply Text",
            'introduction_text': "Sending from {{ context.send_from }}",
            'elements' => [
              {
                'display_name' => "Reply Text",
                'name' => 'reply_text',
                'type' => 'textarea',
                'help_text' => "Type in your message"
              }
            ],
            'submit_label' => "Send",
            'notify_on_cancel' => false,
            'state' => "{{ context.reply_to }}"
          }

        },
        'headers' => {}
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
      return ["Please use #{verbs.join('/').upcase} requests only", 401] unless verbs.include?(method)

      code = (interpolated['code'].presence || 200).to_i



      interpolate_with(params) do
        post_url = interpolated['post_url']
        post_headers = headers(interpolated[:headers])
        post_body = interpolated['payload'].to_json
        post_method = 'post'
        post_headers['Content-Type'] = 'application/json; charset=utf-8'

        response = faraday.run_request(post_method.to_sym, post_url, post_body, post_headers)

      end

      #['Event Created', 200]
      # payload is now ready with the data

      if interpolated['response_headers'].presence
        [interpolated(params)['response'] || 'Event Created', code, "text/plain", interpolated['response_headers'].presence]
      else
        [interpolated(params)['response'] || 'Event Created', code]
      end
    end





#    def check
#    end

#    def receive(incoming_events)
#    end
  end
end

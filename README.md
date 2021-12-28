# MattermostForm



**NOTE** THIS DOES NOT WORK

To trigger the mattermost interactive dialog from a user button, the server
must first respond to and close the connection from mattermost. It then needs
to send the POST message to the actions/open API end point with the trigger_id
within 3 seconds. If you send the POST message before closing the original
connection from mattermost, mattermost will respond with a "status": "OK"
message, but the dialog will not pop up.  The best way to do this is with a webhook agent and chained
post agent, but to satisfy the 3 second rule, you need to adjust the
Delayed::Job sleep timer.  With Huginn you can do this by setting the
environmental variable `DELAYED_JOB_SLEEP_DELAY=1`.  Setting to 1 works, but
increases the load on your server.  2 should work as well or 3 should work most
the time.  

## Example Agents

### Agent for receiving the target of the user button (Webhook Agent)
```javascript
{
   "secret": "supersecretkey",
    "expected_receive_period_in_days": "100",
    "payload_path": ".",
    "code": "200",
    "response": {},
    "response_headers": {
      "Content-Type": "application/json"
    }
}
```
 
### Agent to trigger the interactive dialog 
```javascript
{
  "post_url": "https://mattermost.com/api/v4/actions/dialogs/open",
  "expected_receive_period_in_days": "70",
  "content_type": "json",
  "method": "post",
  "payload": {
    "url": "[Reply Webhook URL]",
    "trigger_id": "{{ trigger_id }}",
    "dialog": {
      "callback_id": "{{ context.send_from }}",
      "title": "Send Reply Text",
      "introduction_text": "Sending from {{ context.send_from }}",
      "elements": [
        {
          "display_name": "Reply Text",
          "name": "reply",
          "type": "textarea",
          "help_text": "Type in your message"
        }
      ],
      "submit_label": "Send",
      "notify_on_cancel": "{% assign bar = false %}{{bar | as_object}}",
      "state": "{{ context.reply_to }}"
    }
  },
  "headers": {
  },
  "emit_events": "true",
  "no_merge": "true",
  "output_mode": "clean"
}
```

Welcome to your new agent gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/huginn_mattermost_form`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

This gem is run as part of the [Huginn](https://github.com/huginn/huginn) project. If you haven't already, follow the [Getting Started](https://github.com/huginn/huginn#getting-started) instructions there.

Add this string to your Huginn's .env `ADDITIONAL_GEMS` configuration:

```ruby
huginn_mattermost_form
# when only using this agent gem it should look like this:
ADDITIONAL_GEMS=huginn_mattermost_form
```

And then execute:

$ bundle

## Usage

TODO: Write usage instructions here

## Development

Running `rake` will clone and set up Huginn in `spec/huginn` to run the specs of the Gem in Huginn as if they would be build-in Agents. The desired Huginn repository and branch can be modified in the `Rakefile`:

```ruby
HuginnAgent.load_tasks(branch: '<your branch>', remote: 'https://github.com/<github user>/huginn.git')
```

Make sure to delete the `spec/huginn` directory and re-run `rake` after changing the `remote` to update the Huginn source code.

After the setup is done `rake spec` will only run the tests, without cloning the Huginn source again.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/huginn_mattermost_form/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

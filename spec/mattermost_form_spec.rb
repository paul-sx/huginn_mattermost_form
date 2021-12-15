require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::MattermostForm do
  before(:each) do
    @valid_options = Agents::MattermostForm.new.default_options
    @checker = Agents::MattermostForm.new(:name => "MattermostForm", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end

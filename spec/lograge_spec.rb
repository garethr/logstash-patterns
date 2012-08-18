require 'spec_helper'

describe "the lograge grok pattern" do

  before do
    @grok = Grok.new
    @grok.add_patterns_from_file("patterns/logstash")
    @grok.add_patterns_from_file("patterns/lograge")
    @grok.compile('%{LOGRAGE}')
  end

  describe "with a standard lograge log line" do
    before do
      log_line = "GET /jobs/833552.json format=json action=jobs#show status=200 duration=58.33 view=40.43 db=15.26"
      @match = @grok.match(log_line)
    end

    it "should have the correct http method value" do
      @match.should have_logstash_field("method").with_value("GET")
    end

    it "should have the correct value for the request duration" do
      @match.should have_logstash_field("duration").with_value("58.33")
    end

    it "should have the correct value for the request view time" do
      @match.should have_logstash_field("view").with_value("40.43")
    end

    it "should have the correct controller and action" do
      @match.should have_logstash_field("controller").with_value("jobs")
      @match.should have_logstash_field("action").with_value("show")
    end
  end

  describe "with a post request" do
    before do
      log_line = "POST /jobs/833552.json format=json action=jobs#show status=200 duration=58.33 view=40.43 db=15.26"
      @match = @grok.match(log_line)
    end

    it "should have the correct http method value" do
      @match.should have_logstash_field("method").with_value("POST")
    end
  end

end

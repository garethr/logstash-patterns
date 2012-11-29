require 'spec_helper'

describe "the lighttpd grok pattern" do

  before do
    @grok = Grok.new
    @grok.add_patterns_from_file("patterns/logstash")
    @grok.add_patterns_from_file("patterns/lighttpd")
    @grok.compile('%{LIGHTTPD}')
  end

  # this covers the following lighttpd acceslog format
  # accesslog.format = "%h %V %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
  #
  # http://redmine.lighttpd.net/projects/1/wiki/Docs_ModAccesslog

  describe "with a custom lighttpd log line" do
    before do
      log_line = '192.168.128.150 staging.ischool.zm - [21/Nov/2012:10:11:35 +0200] "GET /styles/tle_new.css HTTP/1.1" 200 6705 "http://staging.ischool.zm/" "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:14.0) Gecko/20100101 Firefox/14.0.1"'
      @match = @grok.match(log_line)
    end

    it "should have the correct client ip" do
      @match.should have_logstash_field("clientip").with_value("192.168.128.150")
    end

    it "should have the correct http method value" do
      @match.should have_logstash_field("verb").with_value("GET")
    end

    it "should have the correct agent" do
      @match.should have_logstash_field("agent").with_value("\"Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:14.0) Gecko/20100101 Firefox/14.0.1\"")
    end

    it "should have the correct status code" do
      @match.should have_logstash_field("response").with_value("200")
    end

  end

end

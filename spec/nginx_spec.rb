require 'spec_helper'

describe "the extended nginx grok pattern" do

  before do
    @grok = Grok.new
    @grok.add_patterns_from_file("patterns/logstash")
    @grok.add_patterns_from_file("patterns/nginx")
    @grok.compile('%{NGINX}')
  end

  # this covers the following nginx log formatter
  # log_format timed_combined '$remote_addr - $remote_user [$time_local]  '
  #    '"$request" $status $body_bytes_sent '
  #    '"$http_referer" "$http_user_agent" '
  #    '$request_time $upstream_response_time '
  #    '$gzip_ratio $sent_http_x_cache'; 

  describe "with a custom nginx log line" do
    before do
      log_line = '10.234.66.250 - - [26/Aug/2012:12:40:31 +0000]  "GET /trade-tariff/commodities/2204298490?as_of=2012-06-05 HTTP/1.1" 200 6699 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" 0.421 0.418 3.28 -'
      @match = @grok.match(log_line)
    end

    it "should have the correct client ip" do
      @match.should have_logstash_field("clientip").with_value("10.234.66.250")
    end

    it "should have the correct http method value" do
      @match.should have_logstash_field("verb").with_value("GET")
    end

    it "should have the correct agent" do
      @match.should have_logstash_field("agent").with_value("\"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)\"")
    end

    it "should have the correct status code" do
      @match.should have_logstash_field("response").with_value("200")
    end

    it "should have the performance data collected" do
      @match.should have_logstash_field("request_time").with_value("0.421")
      @match.should have_logstash_field("upstream_response_time").with_value("0.418")
      @match.should have_logstash_field("gzip_ratio").with_value("3.28")
    end
  end

end

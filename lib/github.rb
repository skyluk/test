# Defines some utilities for working with the github api.

#require 'ERB'
require 'json'
require 'net/http'

API_TOKEN=ENV["API_TOKEN"]

OWNER="skyluk"
REPO="#{OWNER}/test"

#OWNER="wrktech"
#REPO="#{OWNER}/wrk"
BASE_URL="https://api.github.com/repos/#{REPO}"

# api get
def api_get(url)
  uri = URI("#{BASE_URL}#{url}")
  req = Net::HTTP::Get.new(uri)

  req['Accept'] = "application/vnd.github.v3+json"
  req['Authorization'] = "token #{API_TOKEN}"

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
    http.request(req)
  }

  if not res.kind_of? Net::HTTPSuccess or 
     not res.kind_of? Net::HTTPOK
    raise "API request unsuccessful."
  end

  return JSON[res.body]
end

# Gets the most recent tag from github
def get_last_release
  r = api_get("/releases")

  return r[0]['tag_name']
end

# Determine whether or not a tag is valid
def is_valid_tag(tag)
  return (not tag.empty? and tag =~ /v\d{1,2}\.\d{1,3}/)
end

# Updates the tag version
# e.g. v1.2 -> v1.3
def update_tag_version(tag)
  if not is_valid_tag(tag)
    raise "Invalid tag."
  end

  # remove the 'v'
  #tag = tag[1..]
  t = tag.split('.')

  major = t[0].to_i
  minor = t[1].to_i

  minor += 1

  if minor > MAX_MINOR
    minor = 0
    major += 1
  end

  return "v%d.%d" % [major, minor]
end

# Creates a new release in github
def create_release(tag, message)

  if not is_valid_tag(tag)
    raise "Invalid tag."
  end

  if message.empty?
    raise 
    message = "Release for #{tag}"
  end

  message = {
    "tag_name": tag,
    "target_commitish": "master",
    "name": tag,
    "body": message,
    "draft": false,
    "prerelease": false
  }.to_json

  r = api_post("/releases", message)

  if not r.kind_of? Net::HTTPCreated
    raise "Creation of release unsuccessful."
  end
end

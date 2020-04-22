require "timers"
require "net/http"
require "uri"
require "json"

class Oreki
  def load_config(path)
    File.open(path) do |f|
      @config = JSON.load(f)
    end
  end
  def initialize(config_path)
    @emitter = {}
    @timers = Timers::Group.new
    @started = false
    self.load_config(config_path)
  end
  def on(event, callback)
    @emitter[event] = callback
  end
  def emit(event, data)
    if @emitter[event] != nil
      @emitter[event].call(data)
      return
    end
  end
  def start
    @started = true
    @timers.every(60) {
      self.check_transactions
    }
    while true do
      if !@started
        break
      end
      @timers.wait
    end
  end

  def stop
    @started = false
  end

  def check_transactions
    uri = URI.parse(@config["host"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.protocol == "https"
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    json = {
      "password" => @config["password"]
    }.to_json
    req.body = json
    res = http.request(req)
    resJson = JSON.parse(res.body)
    payments = resJson["payments"]
    payments.each do |payment|
      self.emit("paid", payment)
    end
  end
end

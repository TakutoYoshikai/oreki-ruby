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

  def add_payment(user_id, endpoint, point, price)
    uri = URI.parse(@config["host"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri.request_uri + "payment")
    req["Content-Type"] = "application/json"
    json = {
      "user_id" => user_id,
      "endpoint" => endpoint,
      "point" => point,
      "price" => price,
      "password" => @config["password"]
    }.to_json
    req.body = json
    res = http.request(req)
    if res.code.to_i != 200
      puts res.code
      return nil
    end
    res_json = JSON.parse(res.body)
    payment = res_json["payment"]
    return payment
  end
  def check_transactions
    uri = URI.parse(@config["host"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    json = {
      "password" => @config["password"]
    }.to_json
    req.body = json
    res = http.request(req)
    res_json = JSON.parse(res.body)
    payments = res_json["payments"]
    payments.each do |payment|
      self.emit("paid", payment)
    end
  end
end

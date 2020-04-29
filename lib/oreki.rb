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
    url = @config["host"] + "/payment"
    res_json = send_request(url, {
      "user_id" => user_id,
      "endpoint" => endpoint,
      "point" => point,
      "price" => price,
      "password" => @config["password"]
    })
    if res_json == nil
      return nil
    end
    payment = res_json["payment"]
    return payment
  end
  def check_transactions
    res_json = send_request(@config["host"], {
      "password" => @config["password"]
    })
    if res_json == nil
      return
    end
    payments = res_json["payments"]
    payments.each do |payment|
      self.emit("paid", payment)
    end
  end

  private
  def send_request(url, data)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    json = data.to_json
    req.body = json
    res = http.request(req)
    if res.code.to_i != 200
      return nil
    end
    res_json = JSON.parse(res.body)
    return res_json
  end
end

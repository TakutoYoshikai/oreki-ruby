require "../lib/oreki"
require "test/unit"

class TestOreki < Test::Unit::TestCase
  def test_eventemitter
    def callback(data)
      if data == "data"
        assert true
        return
      end
      assert false
    end
    oreki = Oreki.new("./config.json")
    oreki.on("event", method(:callback))
    oreki.emit("event", "data")
  end

  def test_checktransaction
    oreki = Oreki.new("./config.json")
    def callback(payment)
      assert true
    end
    oreki.on("paid", method(:callback))
    oreki.check_transactions
  end

  def test_addpayment
    oreki = Oreki.new("./config.json")
    payment = oreki.add_payment("user", "endpoint", 10, 100)
    puts payment
    if payment == nil
      assert false
    end
    assert true
  end
end

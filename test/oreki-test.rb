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
    oreki = Oreki.new
    oreki.on("event", method(:callback))
    oreki.emit("event", "data")
  end
end

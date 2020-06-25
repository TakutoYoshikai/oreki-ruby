require "./lib/oreki"

oreki = Oreki.new("./config.json")
def paid(payment)
  puts payment
end
oreki.on("paid", method(:paid))
payment = oreki.add_payment("user", "endpoint", 10, 100)
puts payment["payee"]
#payeeに送金した後、ブロックが取り込まれるとpaidが呼ばれる
oreki.start

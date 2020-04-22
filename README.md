#oreki-ruby
a ruby library of oreki
### import
```
require "./lib/oreki"
```
### initialize
```
oreki = Oreki.new("/path/to/config.json")
```
### add payment
```
payment = oreki.add_payment(<user_id: string>, <endpoint_id: string>, <point: int>, <price: int>)
#payment.address: bitcoin address
```
### register event of getting coin
```
def callback(payment)
  #Please set point to your api from payment object
end
oreki.on("paid", method(:callback))
```

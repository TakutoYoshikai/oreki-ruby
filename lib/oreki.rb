class Oreki
  def initialize()
    @emitter = {}
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
end

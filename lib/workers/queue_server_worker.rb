require 'thread'

class QueueServerWorker < BackgrounDRb::MetaWorker
  set_worker_name :queue_server_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    @queue_list = []
    @queue = Queue.new
    t = Thread.new do
      while true
        pasokara = @queue.deq
        @queue_list.shift
        pasokara.play
      end
    end
  end


  def enqueue(id)
    pasokara = PasokaraFile.find(id)
    @queue_list << id
    cache['queue_list'] = @queue_list
    @queue.enq pasokara
  end
end


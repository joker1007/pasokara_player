module Linux
  module Player
    
    def launch_player(cmd)
      pid = fork {
        exec(cmd)
      }

      th = Process.detach(pid)
      th.join
    end
  end
end

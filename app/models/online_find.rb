# _*_ coding: utf-8 _*_

require "drb/drb"
module OnlineFind

  def self.included(base)
    base.class_eval <<-RUBY
      class << self
        alias :__find :find
      end
    RUBY
    base.extend(ClassMethods)
  end

  module ClassMethods

    def find(*args)
      begin
        queue_server = DRbObject.new_with_uri("druby://localhost:12345")
        online_computers = queue_server.nil? ? [] : queue_server.online_computers
      rescue Exception
        online_computers = []
      end
      conditions = [Array.new(online_computers.size, "computer_name = ?").join(" OR ")] + online_computers

      with_scope(:find => {:conditions => conditions}) do
        __find(*args)
      end
    end
  end
end

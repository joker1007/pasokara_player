# _*_ coding: utf-8 _*_

module OnlineFind

  def self.included(base)
    base.class_eval <<-RUBY
      class << self
        alias :__find :find
        cattr_accessor :online_computers
      end
    RUBY
    base.extend(ClassMethods)
  end

  module ClassMethods
    hostname = `hostname`.chomp
    @@online_computers = [hostname]

    def find(*args)
      conditions = [Array.new(@@online_computers.size, "computer_name = ?").join(" OR ")] + @@online_computers

      with_scope(:find => {:conditions => conditions}) do
        __find(*args)
      end
    end
  end
end

# _*_ coding: utf-8 _*_

module OnlineFind

  def self.included(base)
    base.instance_eval <<-RUBY
      alias :__find :find

      hostname = `hostname`.chomp
      @@online_computers ||= ["phoenix4"]

      def find(*args)
        conditions = [Array.new(@@online_computers.size, "computer_name = ?").join(" OR ")] + @@online_computers

        with_scope(:find => {:conditions => conditions}) do
          super
        end
      end

      def online_computers
        @@online_computers
      end

      def find_options_for_tag_counts(*args)
        conditions = [Array.new(@@online_computers.size, "computer_name = ?").join(" OR ")] + @@online_computers
        options = super
        options[:conditions] = merge_conditions(options[:conditions], conditions)
        options
      end
    RUBY
  end
end

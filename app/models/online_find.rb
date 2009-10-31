# _*_ coding: utf-8 _*_

module OnlineFind

  def self.included(base)
    base.instance_eval <<-RUBY
      alias :__find :find

      def find(*args)
        online_computers_id = Computer.find_all_by_online(true).map {|comp| comp.id}
        conditions = [Array.new(online_computers_id.size, "computer_id = ?").join(" OR ")] + online_computers_id

        with_scope(:find => {:conditions => conditions}) do
          super
        end
      end

      def find_options_for_tag_counts(*args)
        online_computers_id = Computer.find_all_by_online(true).map {|comp| comp.id}
        conditions = [Array.new(online_computers_id.size, "computer_id = ?").join(" OR ")] + online_computers_id
        options = super
        options[:conditions] = merge_conditions(options[:conditions], conditions)
        options
      end
    RUBY
  end
end

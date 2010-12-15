# -*- coding: utf-8 -*-
module Jpmobile
  module Mobile
    class Ipad < AbstractMobile
      # 対応するuser-agentの正規表現
      USER_AGENT_REGEXP = /(iPad)/

      # cookieに対応しているか？
      def supports_cookie?
        true
      end
    end
  end
end


# -*- coding: utf-8 -*-
module Jpmobile
  module Mobile
    class Iphone < AbstractMobile
      # 対応するuser-agentの正規表現
      USER_AGENT_REGEXP = /(iPhone|iPod)/

      # cookieに対応しているか？
      def supports_cookie?
        true
      end
    end
  end
end


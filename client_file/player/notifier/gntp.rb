# _*_ coding: utf-8 _*_
require "ruby_gntp"
require "singleton"

module Notifier
  class Gntp
    include Singleton

    def initialize
      begin
        @@growl = GNTP.new("Ruby/GNTP Pasokara Player")
        @@growl.register({
          :notifications => [
            {
              :name => "Queue",
              :enabled => true,
            },
            {
              :name => "Play",
              :enabled => true,
            },
          ]
        })
      rescue Exception
        @@growl = nil
        puts "NoGrowl"
      end
    end

    def play_notify(name)
      begin
        if @@growl
          @@growl.notify({
            :name => "Play",
            :title => WIN32 ? NKF.nkf("-S -w --cp932", "#{name}") : "#{name}",
            :duration => 4,
            :text => "Playing"
          })
        end
      rescue Exception
        puts "Notify Failed"
      end
    end

    def queue_notify(name)
      begin
        if @@growl
          @@growl.notify({
            :name => "Queue",
            :title => WIN32 ? NKF.nkf("-S -w --cp932", "#{name}") : "#{name}",
            :duration => 4,
            :text => "Queueing",
          })
        end
      rescue Exception
        puts "Notify Failed"
      end
    end
  end
end

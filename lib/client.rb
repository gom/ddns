#!/usr/bin/ruby
#-*- coding: utf-8 -*-
module Ddns
  class Client
    CHECK_PATH = 'http://checkip.dyndns.org/.'

    def log str
      date = Time.now.strftime("%Y%m")
      path = @log_path.sub /\.log/, "#{date}.log"
      open(path, 'a') do |f|
        f.puts "[#{Time.now}] #{str}"
      end
    end

    def current_ip
      unless @current_ip
        open(CHECK_PATH) do |f|
          f.read =~ /((\d{1,3}\.){3}\d{1,3})/
          @current_ip = $1
        end
      end
      @current_ip
    end

    def check
      current_ip == read_ip
    end

    def no_change
      log "no ip change: #{current_ip}"
    end

    def set_config
      @config = YAML.load_file(@yaml_path)
    end

    def create_ip
      unless File.exist? @ip_path
        open(@ip_path, 'w') {|f| f.puts 'ip:' }
      end
    end

    def read_ip
      unless @saved_ip
        create_ip
        y = YAML.load_file(@ip_path)
        @saved_ip = y['ip']
      end
      @saved_ip
    end

    def write_ip
      open(@ip_path, 'w') do |f|
        f.puts YAML.dump({'ip' => current_ip})
      end
    end

    def update
      @config.each do |conf|
        myhost = conf['myhost']

        options = {:http_basic_authentication => [conf['id'],conf['pass']],
          "User-Agent" => "#{myhost} - Ruby/#{RUBY_VERSION} - 0.01" }
        params = "hostname=#{myhost}&myip=#{current_ip}"
        result = ''
        open("http://members.dyndns.org/nic/update?#{params}", options) do |f|
          result = f.read
          log "#{myhost}: "+ result
        end
        if result =~ /err/
          log "[#{myhost}]: Update Error!! " + result
        end
      end
    end

    def set_filepath
      pwd = File.dirname(File.dirname(File.expand_path(__FILE__)))
      @yaml_path = File.join(pwd, 'config', 'config.yml')
      @ip_path   = File.join(pwd, 'config', 'ipaddr.yml')
      @log_path  = File.join(pwd, 'log', 'ddns.log')
    end

    def run_update
      set_filepath
      set_config
      if check
        no_change
      else
        update
        write_ip
      end
  end
  end
end

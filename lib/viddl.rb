require "rubygems"
require "nokogiri"
require "cgi"
require "open-uri"
require "viddl/plugin-base"

module Viddl
  class Parser
    def initialize
      $LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'helper')
      puts "Loading Plugins"
      puts File.dirname(__FILE__)
      Dir[File.join(File.dirname(__FILE__),"../plugins/*.rb")].each do |plugin|
        load plugin
      end
    end

    def parse(url)
      download_queue = nil
      PluginBase.registered_plugins.each do |plugin|
        if plugin.matches_provider?(url)
          begin
            download_queue = plugin.get_urls_and_filenames(url)
          rescue StandardError => e
            puts "Error while running the #{plugin.name.inspect} plugin. Maybe it has to be updated? Error: #{e.message}: #{e.inspect}"
            exit
          end
        end
      end

      download_queue
    end

    def unescape_uri(uri)
      u = CGI::unescape(uri)
      u.gsub(/; .*/, '')
    end
  end
end

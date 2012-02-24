#!/usr/bin/env ruby

require 'anemone'
require 'uri'

class Ant
  @opts = { :obey_robots_txt => true,
            :dealy => 1,
            :user_agent => 'Anthill.ant, https://github.com/nmichalov' }
  def initialize( target_url )
    @domain = target_url
    url = URI(@domain)
    @url_dir = url.host.gsub(/\./, ' ')
    begin
    Dir::mkdir(@url_dir)
    rescue
    end
  end
  def crawl
    Anemone.crawl(@domain) do |anemone|
      anemone.on_every_page do |page|
        out_file = page.url.to_s().gsub(/\//, ' SLASH ')
        out_file = out_file.gsub(/\:/, ' COL ')
        page = page.body
        doc = Nokogiri::HTML(page)
        doc.xpath('//p/text()').each do |p_tag|
          File.open(@url_dir + '/' + out_file, 'a') { |f| f.write(p_tag.content) }
        end
        links = doc.xpath('//a').collect { |a_tag| a_tag['href'] }
        File.open(@url_dir + '/links ' + out_file, 'w') do |file|
          Marshal.dump(links, file)
        end
      end
    end
  end
end

na = Ant.new('http://www.hackerschool.com')
na.crawl

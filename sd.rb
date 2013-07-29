require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'parallel'
require 'uri'

class StanfordDownload

  def initialize()
    @cookie = '__utma=94604366.542495031.1358987756.1374955974.1374972248.3; __utmc=94604366; __utmz=94604366.1374955974.2.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); sessionid=6643912f692119de7bf55df487f8c22d; csrftoken=zDU4ruW0vxzQF6sMS750DGEQbvrZbXMq; AWSELB=09E917B50A396EF0F3A455F1D5CFD6870CF08E3E52CC4F3DF9B7022D913169D8F94C920568A63951289098DAB7B36448D9E6787A729C3F4F05395BE4DBA022B39F687DDF3E'
    @base_url = 'http://class2go.stanford.edu'
    @link_list_path = '/db/Winter2013/leftnav'
    @dest_dir = './vids'
  end

  def getSectionUrls
    puts "Fetching list of section URLS...\n"
    link_list_page = Nokogiri::HTML(open(@base_url + @link_list_path, "Cookie" => @cookie))
    link_list_page.css('a[title="Video"]').map do |link|
      @base_url + link['href']
    end
  end

  def getVideoUrlFromSection section_url
    video_page = Nokogiri::HTML(open(section_url, "Cookie" => @cookie))
    video_page.css('a[title="Download lecture video as mp4"]')[0]['href']
  end

  def downloadVideos
    puts "Downloading videos...\n"

    Dir.mkdir(@dest_dir) unless File.directory?(@dest_dir)

    Parallel.each(getSectionUrls(), :in_threads => 4) do |section_url|

      puts "Getting video URL from section #{section_url}...\n"
      vid_url = getVideoUrlFromSection(section_url)
      filename = File.basename(URI.parse(vid_url).path)

      puts "Downloading #{filename}...\n"
      File.open(@dest_dir + '/' + filename, "wb") do |local_file|
        open(vid_url, 'rb') do |remote_file|
          local_file.write(remote_file.read)
        end
      end
      puts "Finished downloading #{filename}!\n"

    end

  end

end

if __FILE__ === $0
  sd = StanfordDownload.new()
  sd.downloadVideos()
end

require 'open-uri'
require 'nokogiri'
require 'fastimage'

# Link to all themes, displayed page by page
# Page number is replaced by %s
LIST_URL = 'https://atom.io/themes/list?direction=desc&page=%s&sort=downloads'
# Link to detail page for a theme
DETAIL_URL = 'https://atom.io/themes/%s'
# Where to save the theme images
SAVE_DIR = './app/assets/images/'
# List of themes to ingnore
BLACKLIST = './config/blacklist.yml'


desc 'Update theme database using atom.io'
task :update_themes => :environment do
  Theme.delete_all

  blacklist = YAML.load_file(BLACKLIST)
  fetch_all_themes.each do |theme_name|
    next if blacklist.include? theme_name
    save_theme_details(fetch_detail_page(theme_name))
  end
end

def fetch_list_page(page_number)
  return Nokogiri::HTML(open(LIST_URL % page_number))
end

def fetch_detail_page(theme_name)
  return Nokogiri::HTML(open(DETAIL_URL % theme_name))
end

def themes_from_page(page)
  themes = Array.new
  page.css('h4.card-name').each do |card|
    themes.push(card.content.strip)
  end
  return themes
end

def fetch_all_themes
  themes = Array.new

  for page_number in 1..1000
    page = fetch_list_page(page_number)
    new_themes = themes_from_page(page)
    if new_themes.length == 0
      break
    end
    themes += new_themes
  end

  return themes
end

def save_theme_details(detail_page)
  theme_name = detail_page.css('title').first.content.strip
  found_image = save_good_image(detail_page)
  repo_url = detail_page.css('span.octicon-repo').first.parent.attr('href')
  repo_name = repo_url.gsub('https://github.com/', '')
  downloads = detail_page.css('span.octicon-cloud-download').first.next_element.content
  downloads = downloads.gsub(',','').to_i
  stars = detail_page.css('a.social-count').first.content.to_i

  if found_image
    theme = Theme.new(:name => theme_name, :repo => repo_name,
      :downloads => downloads, :stars => stars)
    theme.save
    puts 'Saved new theme "%s" into database' % theme_name
  end
end

def save_good_image(detail_page)
  theme_name = detail_page.css('title').first.content.strip

  found_image = false
  images_from_page(detail_page).each do |img_src|
    next unless (img_src.include? '.png')

    begin
      dimensions = FastImage.size(img_src)
      if dimensions.first > 150 && dimensions.last > 150
        image = open(img_src)
        save_image(image, SAVE_DIR+theme_name+'-first.png')
        found_image = true
      end
    rescue RuntimeError, NoMethodError
      puts 'Error fetching image for '+theme_name
    end

    break if found_image
  end

  return found_image
end

def images_from_page(detail_page)
  img_srcs = Array.new
  detail_page.css('div.readme').css('img[data-canonical-src]').each do |img|
    img_srcs.push(img.attr('data-canonical-src'))
  end
  return img_srcs
end

def save_image(image, filename)
  File.open(filename, 'wb') do |file|
    file.puts image.read
  end
end

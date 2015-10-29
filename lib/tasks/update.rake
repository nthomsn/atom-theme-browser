require 'open-uri'
require 'nokogiri'

# Link to all themes, displayed page by page
# Page number is replaced by %s
LIST_URL = 'https://atom.io/themes/list?direction=desc&page=%s&sort=downloads'
# Link to detail page for a theme
DETAIL_URL = 'https://atom.io/themes/%s'
# Where to save the theme images
SAVE_DIR = './app/assets/images/'

desc 'Update theme database using atom.io'
task :update_themes => :environment do
  fetch_all_themes.each do |theme_name|
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

  for page_number in 1..1
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

  images_from_page(detail_page).each do |img_src|
    if (img_src.include? '.png')
      puts 'Found image for '+theme_name
      begin
        save_image(open(img_src), SAVE_DIR+theme_name+'-first.png')
      rescue RuntimeError
        puts 'Error fetching image for '+theme_name
      end
      break # Only save one image
    end
  end

end

def images_from_page(detail_page)
  img_srcs = Array.new
  detail_page.css('div.readme').css('img[src]').each do |img|
    img_srcs.push(img.attr('data-canonical-src'))
  end
  return img_srcs
end

def save_image(image, filename)
  File.open(filename, 'wb') do |file|
    file.puts image.read
  end
end

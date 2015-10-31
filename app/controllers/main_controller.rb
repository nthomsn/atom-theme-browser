class MainController < ApplicationController
  def index
    @themes = Theme.order(downloads: :desc).page(1).per(20)
  end

  def pretty_theme_name(name)
    pretty = name.gsub('-', ' ')
    return pretty.titleize
  end

  def pretty_number(num)
    if num > 999
      return (num/1000).to_s + 'k'
    end
    return num
  end

  helper_method :pretty_theme_name
  helper_method :pretty_number
end

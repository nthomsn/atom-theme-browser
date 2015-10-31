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

  def repo_link(repo_name)
    return 'https://github.com/' + repo_name
  end

  helper_method :pretty_theme_name
  helper_method :pretty_number
  helper_method :repo_link
end

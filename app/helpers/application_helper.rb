module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title = ""
    base_title = "Ruby on Rails Tutorial Sample App"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def render_flash
    flashes = flash.map do |type, message|
      bootstrap_class = case type.to_sym
                        when :notice  then "alert alert-success"
                        when :alert   then "alert alert-danger"
                        when :success then "alert alert-success"
                        when :danger  then "alert alert-danger"
                        when :warning then "alert alert-warning"
                        else "alert alert-info"
                        end

      content_tag :div, message, class: ["alert", bootstrap_class].join(" ")
    end

    safe_join(flashes)
  end
end

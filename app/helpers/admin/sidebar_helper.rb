module Admin::SidebarHelper
  def active_under? prefix
    request.path.start_with?(prefix) ? "active" : ""
  end
end

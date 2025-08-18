module Admin::SidebarHelper
  def active_under? prefix
    controller_path.start_with?(prefix) ? "active" : ""
  end
end

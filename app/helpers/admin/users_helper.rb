module Admin::UsersHelper
  def user_status_filter_options
    [
      [t("admin.users.filter.all"), ""],
      [t("admin.users.filter.active"), true],
      [t("admin.users.filter.unactive"), false]
    ]
  end
end

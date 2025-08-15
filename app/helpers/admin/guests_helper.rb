module Admin::GuestsHelper
  def identity_type_options
    [
      [t(".national_id"), :national_id],
      [t(".passport"), :passport],
      [t(".identity_number"), :identity_number]
    ]
  end
end

module RoomsHelper
  def room_type_options
    RoomType.pluck(:name)
  end

  def price_range_options
    [
      [t("rooms.filter.below_50"), "below_50"],
      [t("rooms.filter.from_50_99"), "50_99"],
      [t("rooms.filter.from_100_200"), "100_200"],
      [t("rooms.filter.above_200"), "above_200"]
    ]
  end

  def sort_by_options
    [
      [t("rooms.filter.price_asc"), :price_asc],
      [t("rooms.filter.price_desc"), :price_desc],
      [t("rooms.filter.rating_desc"), :rating_desc]
    ]
  end
end

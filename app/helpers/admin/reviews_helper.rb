module Admin::ReviewsHelper
  def review_status_options
    [
      [t(".all"), ""],
      [t(".pending"), Review.review_statuses[:pending]],
      [t(".approved"), Review.review_statuses[:approved]],
      [t(".rejected"), Review.review_statuses[:rejected]]
    ]
  end

  def rating_options
    [
      [t(".all"), ""]
    ] + Review::RATINGS.map {|n| [n.to_s, n]}
  end
end

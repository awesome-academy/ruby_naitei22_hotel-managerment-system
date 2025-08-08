require "pagy/extras/bootstrap"
require "pagy/extras/overflow"

# Optionally override some pagy default with your own in the pagy initializer
Pagy::DEFAULT[:limit] = 5 # items per page
Pagy::DEFAULT[:size]  = 9  # nav bar links
# Better user experience handled automatically
Pagy::DEFAULT[:overflow] = :last_page

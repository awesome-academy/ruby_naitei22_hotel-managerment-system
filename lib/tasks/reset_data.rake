namespace :db do
  desc "Reset DB và seed lại"
  task reset_data: :environment do
    Rake::Task["db:reset"].invoke
    puts "👉 Reset xong, đang chạy seed..."
    Rake::Task["db:seed"].invoke
    puts "🎉 Done!"
  end
end

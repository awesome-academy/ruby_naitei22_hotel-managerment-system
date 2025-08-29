namespace :db do
  desc "Rollback toàn bộ và migrate lại từ đầu"
  task reset_migrate: :environment do
    puts "👉 Đang rollback toàn bộ migration..."
    Rake::Task["db:migrate:reset"].invoke
    puts "🎉 Đã migrate lại DB từ đầu!"
  end
end

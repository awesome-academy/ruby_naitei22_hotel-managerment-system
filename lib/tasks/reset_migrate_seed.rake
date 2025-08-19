namespace :db do
  desc "Rollback toàn bộ, migrate lại từ đầu và seed dữ liệu"
  task reset_migrate_and_seed: :environment do
    puts "👉 Đang rollback toàn bộ migration và migrate lại..."
    Rake::Task["db:migrate:reset"].invoke

    puts "👉 Đang seed dữ liệu..."
    Rake::Task["db:seed"].invoke

    puts "🎉 Hoàn tất migrate + seed!"
  end
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require "support_rota_to_productive"

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: %i[spec]

namespace :support_rota_to_productive do
  namespace :import do
    desc "Import upcoming support shifts from support rota app into Productive"
    task :run do
      SupportRotaToProductive::Import.new.run
    end

    desc "Do a dry run of importing upcoming support shifts from support rota app to Productive"
    task :dry_run do
      SupportRotaToProductive::Import.new(dry_run: true).run
    end
  end
end

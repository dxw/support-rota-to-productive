require "rake"

module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) { self.class.description.delete_prefix("rake ") }
    let(:tasks) { Rake::Task }

    # Make the Rake task available as `task` in your examples:
    subject(:task) { tasks[task_name] }
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/lib/tasks/}) do |metadata|
    metadata[:type] = :task
  end

  config.include TaskExampleGroup, type: :task

  config.before(:suite) do
    Rake.load_rakefile("Rakefile")
  end
end

require "spec_helper"

describe "Rake tasks" do
  let(:double) { instance_double("SupportRotaToProductive::Import", run: nil) }

  describe "rake support_rota_to_productive:import:dry_run", type: :task do
    it "does a dry run" do
      expect(
        SupportRotaToProductive::Import
      ).to receive(:new).with(dry_run: true) { double }

      task.execute
    end
  end

  describe "rake support_rota_to_productive:import:run", type: :task do
    it "carries out an import" do
      expect(
        SupportRotaToProductive::Import
      ).to receive(:new).with(no_args) { double }

      task.execute
    end
  end
end

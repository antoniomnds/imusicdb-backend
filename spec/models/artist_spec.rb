require 'rails_helper'

RSpec.describe Artist, type: :model do
  subject(:artist) { create(:artist) }

  describe "model validations" do
    context "#name" do
      it "is required" do
        artist.name = nil
        artist.valid?
        expect(artist.errors[:name].first).to match(/blank/)
      end
    end
  end
end

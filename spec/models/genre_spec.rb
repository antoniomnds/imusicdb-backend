require 'rails_helper'

RSpec.describe Genre, type: :model do
  subject(:genre) { create(:genre) }

  describe "model validations" do
    context "#name" do
      it "is required" do
        genre.name = nil
        genre.valid?
        expect(genre.errors[:name].first).to match(/blank/)
      end
    end
  end
end

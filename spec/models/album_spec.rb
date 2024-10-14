require 'rails_helper'

RSpec.describe Album, type: :model do
  let(:album) { create(:album) }

  describe "model validations" do
    context "#name" do
      it "is required" do
        album.name = nil
        album.valid?
        expect(album.errors[:name].first).to match(/blank/)
      end
    end

    context "#total_tracks" do
      it "is_required" do
        album.total_tracks = nil
        album.valid?
        expect(album.errors[:total_tracks].first).to match(/blank/)
        expect(album.errors[:total_tracks].last).to match(/is not a number/)
      end

      it "should be an integer" do
        album.total_tracks = 1.1
        album.valid?
        expect(album.errors[:total_tracks].first).to match(/integer/)
      end

      it "should be a positive number" do
        album.total_tracks = 0
        album.valid?
        expect(album.errors[:total_tracks].first).to match(/must be greater than/)
      end
    end

    context "#release_date" do
      it "is_required" do
        album.release_date = nil
        album.valid?
        expect(album.errors[:release_date].first).to match(/blank/)
      end
    end

    context "#label" do
      it "is_required" do
        album.label = nil
        album.valid?
        expect(album.errors[:label].first).to match(/blank/)
      end
    end
  end
end

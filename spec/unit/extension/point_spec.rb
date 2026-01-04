# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Geometry::Point extensions" do
  using ChemScanner::Extension

  let(:point) { Geometry::Point.new(0.0, 0.0) }

  describe "#distance_to" do
    it "calculates distance to another point" do
      other = Geometry::Point.new(3.0, 4.0)
      expect(point.distance_to(other)).to eq(5.0)
    end

    it "returns 0 for same point" do
      expect(point.distance_to(point)).to eq(0.0)
    end

    it "handles negative coordinates" do
      other = Geometry::Point.new(-3.0, -4.0)
      expect(point.distance_to(other)).to eq(5.0)
    end
  end

  describe "#euclid_distance_to_polygon" do
    let(:polygon) do
      Geometry::Polygon.new([
                              Geometry::Point.new(10.0, 0.0),
                              Geometry::Point.new(10.0, 10.0),
                              Geometry::Point.new(20.0, 10.0),
                              Geometry::Point.new(20.0, 0.0),
                            ])
    end

    it "calculates distance to polygon" do
      dist = point.euclid_distance_to_polygon(polygon)
      expect(dist).to eq(10.0)
    end
  end
end

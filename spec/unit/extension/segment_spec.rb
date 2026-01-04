# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Geometry::Segment extensions" do
  using ChemScanner::Extension

  let(:p1) { Geometry::Point.new(0.0, 0.0) }
  let(:p2) { Geometry::Point.new(10.0, 0.0) }
  let(:segment) { Geometry::Segment.new(p1, p2) }

  describe "#points" do
    it "returns array of point1 and point2" do
      expect(segment.points).to eq([p1, p2])
    end
  end

  describe "#contains_point?" do
    it "returns true for point on segment" do
      midpoint = Geometry::Point.new(5.0, 0.0)
      expect(segment.contains_point?(midpoint)).to eq(true)
    end

    it "returns true for endpoints" do
      expect(segment.contains_point?(p1)).to eq(true)
      expect(segment.contains_point?(p2)).to eq(true)
    end

    it "returns false for point not on segment" do
      off_point = Geometry::Point.new(5.0, 5.0)
      expect(segment.contains_point?(off_point)).to eq(false)
    end

    it "returns false for point on line but outside segment" do
      outside = Geometry::Point.new(15.0, 0.0)
      expect(segment.contains_point?(outside)).to eq(false)
    end
  end

  describe "#contains_segment?" do
    it "returns true when other segment is fully contained" do
      inner_seg = Geometry::Segment.new(
        Geometry::Point.new(2.0, 0.0),
        Geometry::Point.new(8.0, 0.0),
      )
      expect(segment.contains_segment?(inner_seg)).to eq(true)
    end

    it "returns false when other segment extends beyond" do
      outer_seg = Geometry::Segment.new(
        Geometry::Point.new(-2.0, 0.0),
        Geometry::Point.new(5.0, 0.0),
      )
      expect(segment.contains_segment?(outer_seg)).to eq(false)
    end
  end

  describe "#center" do
    it "returns midpoint of segment" do
      center = segment.center
      expect(center.x).to eq(5.0)
      expect(center.y).to eq(0.0)
    end

    context "with non-horizontal segment" do
      let(:diagonal) do
        Geometry::Segment.new(Geometry::Point.new(0, 0),
                              Geometry::Point.new(4, 4))
      end

      it "returns correct center" do
        center = diagonal.center
        expect(center.x).to eq(2.0)
        expect(center.y).to eq(2.0)
      end
    end
  end

  describe "#to_line" do
    it "returns Line from segment" do
      line = segment.to_line
      expect(line).to be_a(Geometry::Line)
    end
  end

  describe "#euclid_distance_to_point" do
    it "returns minimum distance from segment endpoints to point" do
      point = Geometry::Point.new(0.0, 3.0)
      dist = segment.euclid_distance_to_point(point)
      expect(dist).to eq(3.0)
    end
  end

  describe "#euclid_distance_to" do
    it "returns minimum distance between segment endpoints" do
      other = Geometry::Segment.new(
        Geometry::Point.new(5.0, 5.0),
        Geometry::Point.new(10.0, 5.0),
      )
      dist = segment.euclid_distance_to(other)
      expect(dist).to eq(5.0)
    end
  end

  describe "#head_perpen_points_dist" do
    it "returns two points perpendicular to segment at head" do
      points = segment.head_perpen_points_dist(1.0)
      expect(points.length).to eq(2)
      expect(points[0]).to be_a(Geometry::Point)
      expect(points[1]).to be_a(Geometry::Point)
    end

    it "points are at correct distance" do
      points = segment.head_perpen_points_dist(1.0)
      dist_between = Geometry.distance(points[0], points[1])
      expect(dist_between).to be_within(0.01).of(2.0)
    end
  end

  describe "#tail_perpen_points_dist" do
    it "returns two points perpendicular to segment at tail" do
      points = segment.tail_perpen_points_dist(1.0)
      expect(points.length).to eq(2)
    end
  end

  describe "#slice_to_many_points" do
    it "returns empty array for num < 2" do
      expect(segment.slice_to_many_points(1)).to eq([])
    end

    it "returns n points evenly distributed" do
      points = segment.slice_to_many_points(3)
      expect(points.length).to eq(3)
    end
  end

  describe "#to_gis" do
    it "returns GIS format string" do
      result = segment.to_gis
      expect(result).to include("SEGMENT")
      expect(result).to include("0.0")
      expect(result).to include("10.0")
    end
  end
end

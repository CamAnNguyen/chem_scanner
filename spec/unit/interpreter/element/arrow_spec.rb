# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::Interpreter::Arrow do
  let(:geometry) do
    double(
      "Geometry",
      id: 1,
      tail: { x: 0.0, y: 0.0 },
      head: { x: 10.0, y: 0.0 },
      cross?: false,
      line_type: 0,
      get_tempid: 999,
    )
  end

  let(:arrow) { described_class.new(geometry) }

  describe "#initialize" do
    it "sets id from geometry" do
      expect(arrow.id).to eq(1)
    end

    it "creates tail point from geometry" do
      expect(arrow.tail.x).to eq(0.0)
      expect(arrow.tail.y).to eq(0.0)
    end

    it "creates head point from geometry" do
      expect(arrow.head.x).to eq(10.0)
      expect(arrow.head.y).to eq(0.0)
    end

    it "initializes with empty middle_points" do
      expect(arrow.middle_points).to eq([])
    end

    it "sets cross from geometry" do
      expect(arrow.cross).to eq(false)
    end

    it "sets line_type from geometry" do
      expect(arrow.line_type).to eq(0)
    end

    it "initializes with empty reagents_polygons" do
      expect(arrow.reagents_polygons).to eq([])
    end

    it "initializes height to 0" do
      expect(arrow.height).to eq(0)
    end
  end

  describe "#points" do
    it "returns array of tail, middle_points, and head" do
      expect(arrow.points.length).to eq(2)
      expect(arrow.points.first.x).to eq(0.0)
      expect(arrow.points.last.x).to eq(10.0)
    end

    context "with middle points" do
      before do
        arrow.middle_points = [Geometry::Point.new(5.0, 1.0)]
      end

      it "includes middle points" do
        expect(arrow.points.length).to eq(3)
        expect(arrow.points[1].x).to eq(5.0)
      end
    end
  end

  describe "#segments" do
    it "returns segments connecting points" do
      segments = arrow.segments
      expect(segments.length).to eq(1)
    end

    context "with middle points" do
      before do
        arrow.middle_points = [Geometry::Point.new(5.0, 1.0)]
      end

      it "returns multiple segments" do
        segments = arrow.segments
        expect(segments.length).to eq(2)
      end
    end
  end

  describe "#head_segment" do
    it "returns segment from last point to head" do
      segment = arrow.head_segment
      expect(segment.point1.x).to eq(0.0)
      expect(segment.point2.x).to eq(10.0)
    end

    context "with middle points" do
      before do
        arrow.middle_points = [Geometry::Point.new(5.0, 1.0)]
      end

      it "returns segment from last middle point to head" do
        segment = arrow.head_segment
        expect(segment.point1.x).to eq(5.0)
        expect(segment.point2.x).to eq(10.0)
      end
    end
  end

  describe "#tail_segment" do
    it "returns segment from first point to tail" do
      segment = arrow.tail_segment
      expect(segment.point1.x).to eq(10.0)
      expect(segment.point2.x).to eq(0.0)
    end

    context "with middle points" do
      before do
        arrow.middle_points = [Geometry::Point.new(5.0, 1.0)]
      end

      it "returns segment from first middle point to tail" do
        segment = arrow.tail_segment
        expect(segment.point1.x).to eq(5.0)
        expect(segment.point2.x).to eq(0.0)
      end
    end
  end

  describe "#tail_head_segment" do
    it "returns direct segment from tail to head" do
      segment = arrow.tail_head_segment
      expect(segment.point1.x).to eq(0.0)
      expect(segment.point2.x).to eq(10.0)
    end
  end

  describe "#add_cross_segment" do
    let(:other_segment) do
      Geometry::Segment.new(Geometry::Point.new(5, -5),
                            Geometry::Point.new(5, 5))
    end

    it "adds segment to cross_lines" do
      arrow.add_cross_segment(other_segment)
      expect(arrow.cross_lines).to include(other_segment)
    end

    it "sets cross to true" do
      arrow.add_cross_segment(other_segment)
      expect(arrow.cross).to eq(true)
    end
  end

  describe "#change_head" do
    it "moves current head to middle_points and sets new head" do
      arrow.change_head({ x: 15.0, y: 2.0 })
      expect(arrow.middle_points.length).to eq(1)
      expect(arrow.middle_points.first.x).to eq(10.0)
      expect(arrow.head.x).to eq(15.0)
      expect(arrow.head.y).to eq(2.0)
    end
  end

  describe "#change_tail" do
    let(:new_tail) { Geometry::Point.new(-5.0, 1.0) }

    it "moves current tail to middle_points and sets new tail" do
      arrow.change_tail(new_tail)
      expect(arrow.middle_points.length).to eq(1)
      expect(arrow.middle_points.first.x).to eq(0.0)
      expect(arrow.tail.x).to eq(-5.0)
    end
  end

  describe "#update_tail" do
    let(:new_tail) { Geometry::Point.new(-5.0, 1.0) }

    it "updates tail position without modifying middle_points" do
      arrow.update_tail(new_tail)
      expect(arrow.middle_points).to be_empty
      expect(arrow.tail.x).to eq(-5.0)
    end
  end

  describe "#build_polygons" do
    it "sets height" do
      arrow.build_polygons(2.0)
      expect(arrow.height).to eq(2.0)
    end

    it "creates reagents_polygons" do
      arrow.build_polygons(2.0)
      expect(arrow.reagents_polygons).not_to be_empty
    end
  end

  describe "#dist_to_head" do
    it "calculates distance from point to head" do
      point = Geometry::Point.new(5.0, 0.0)
      expect(arrow.dist_to_head(point)).to eq(5.0)
    end
  end

  describe "#dist_to_tail" do
    it "calculates distance from point to tail" do
      point = Geometry::Point.new(5.0, 0.0)
      expect(arrow.dist_to_tail(point)).to eq(5.0)
    end
  end

  describe "#parallel_to?" do
    let(:parallel_geometry) do
      double(
        "Geometry",
        id: 2,
        tail: { x: 0.0, y: 5.0 },
        head: { x: 10.0, y: 5.0 },
        cross?: false,
        line_type: 0,
        get_tempid: 998,
      )
    end
    let(:parallel_arrow) { described_class.new(parallel_geometry) }

    let(:non_parallel_geometry) do
      double(
        "Geometry",
        id: 3,
        tail: { x: 0.0, y: 0.0 },
        head: { x: 0.0, y: 10.0 },
        cross?: false,
        line_type: 0,
        get_tempid: 997,
      )
    end
    let(:non_parallel_arrow) { described_class.new(non_parallel_geometry) }

    it "returns true for parallel arrows" do
      expect(arrow.parallel_to?(parallel_arrow)).to eq(true)
    end

    it "returns false for non-parallel arrows" do
      expect(arrow.parallel_to?(non_parallel_arrow)).to eq(false)
    end
  end

  describe "#clone" do
    before do
      arrow.height = 2.0
      arrow.cross = true
    end

    it "creates a copy with new id" do
      cloned = arrow.clone
      expect(cloned.id).to eq(999)
    end

    it "clones the tail point" do
      cloned = arrow.clone
      expect(cloned.tail.x).to eq(arrow.tail.x)
      expect(cloned.tail).not_to be(arrow.tail)
    end

    it "clones the head point" do
      cloned = arrow.clone
      expect(cloned.head.x).to eq(arrow.head.x)
      expect(cloned.head).not_to be(arrow.head)
    end

    it "preserves height" do
      cloned = arrow.clone
      expect(cloned.height).to eq(2.0)
    end

    it "preserves cross" do
      cloned = arrow.clone
      expect(cloned.cross).to eq(true)
    end
  end

  describe "#inspect" do
    it "returns string representation" do
      result = arrow.inspect
      expect(result).to include("#<Arrow:")
      expect(result).to include("id=1")
    end
  end

  describe "#get_tempid" do
    it "delegates to geometry" do
      expect(arrow.get_tempid).to eq(999)
    end
  end
end

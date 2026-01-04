# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::Interpreter::ReactionStep do
  let(:step) { described_class.new }

  describe "#initialize" do
    it "sets number to 0" do
      expect(step.number).to eq(0)
    end

    it "sets description to empty string" do
      expect(step.description).to eq("")
    end

    it "sets time to empty string" do
      expect(step.time).to eq("")
    end

    it "sets temperature to empty string" do
      expect(step.temperature).to eq("")
    end

    it "sets reagents to empty array" do
      expect(step.reagents).to eq([])
    end
  end

  describe "attribute accessors" do
    it "allows setting number" do
      step.number = 1
      expect(step.number).to eq(1)
    end

    it "allows setting description" do
      step.description = "Hydrogenation"
      expect(step.description).to eq("Hydrogenation")
    end

    it "allows setting time" do
      step.time = "2 hours"
      expect(step.time).to eq("2 hours")
    end

    it "allows setting temperature" do
      step.temperature = "80 C"
      expect(step.temperature).to eq("80 C")
    end

    it "allows setting reagents" do
      step.reagents = ["H2", "Pd/C"]
      expect(step.reagents).to eq(["H2", "Pd/C"])
    end
  end

  describe "#to_hash" do
    before do
      step.number = 1
      step.description = "Reduction"
      step.time = "3h"
      step.temperature = "25C"
      step.reagents = ["NaBH4"]
    end

    it "returns hash representation" do
      hash = step.to_hash
      expect(hash).to be_a(Hash)
    end

    it "includes number" do
      expect(step.to_hash[:number]).to eq(1)
    end

    it "includes description" do
      expect(step.to_hash[:description]).to eq("Reduction")
    end

    it "includes time" do
      expect(step.to_hash[:time]).to eq("3h")
    end

    it "includes temperature" do
      expect(step.to_hash[:temperature]).to eq("25C")
    end

    it "includes reagents" do
      expect(step.to_hash[:reagents]).to eq(["NaBH4"])
    end
  end

  describe "#inspect" do
    before do
      step.number = 2
      step.description = "Oxidation"
    end

    it "returns string representation" do
      result = step.inspect
      expect(result).to include("#<ReactionStep:")
      expect(result).to include("number=2")
      expect(result).to include("Oxidation")
    end
  end
end

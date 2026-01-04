# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::Abbreviation do
  let(:abbreviation) { described_class.instance }

  describe "#all" do
    it "returns hash combining predefined and custom abbreviations" do
      result = abbreviation.all
      expect(result).to be_a(Hash)
    end

    it "includes predefined abbreviations" do
      expect(abbreviation.all).to include(abbreviation.predefined)
    end
  end

  describe "#predefined" do
    it "returns hash of predefined abbreviations" do
      expect(abbreviation.predefined).to be_a(Hash)
    end

    it "includes solvents" do
      expect(abbreviation.predefined).to include(abbreviation.solvents)
    end
  end

  describe "#solvents" do
    it "returns hash of solvents" do
      expect(abbreviation.solvents).to be_a(Hash)
    end

    it "contains common solvents" do
      solvents = abbreviation.solvents
      expect(solvents.keys).not_to be_empty
    end
  end

  describe "#get_abbreviation" do
    context "when abbreviation exists" do
      it "returns the SMILES for a known abbreviation" do
        abbreviation.predefined.each do |abb, smi|
          result = abbreviation.get_abbreviation(abb)
          expect(result).to eq(smi)
          break
        end
      end

      it "is case-insensitive" do
        first_abb = abbreviation.predefined.keys.first.to_s
        result_lower = abbreviation.get_abbreviation(first_abb.downcase)
        result_upper = abbreviation.get_abbreviation(first_abb.upcase)
        expect(result_lower).to eq(result_upper)
      end
    end

    context "when abbreviation does not exist" do
      it "returns empty string" do
        result = abbreviation.get_abbreviation("NONEXISTENT_ABBREVIATION_XYZ123")
        expect(result).to eq("")
      end
    end
  end

  describe "#custom" do
    it "returns hash of custom abbreviations" do
      expect(abbreviation.custom).to be_a(Hash)
    end
  end
end

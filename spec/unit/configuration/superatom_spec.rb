# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::Superatom do
  let(:superatom) { described_class.instance }

  describe "#all" do
    it "returns hash combining predefined and custom superatoms" do
      result = superatom.all
      expect(result).to be_a(Hash)
    end

    it "is not empty" do
      expect(superatom.all.keys).not_to be_empty
    end
  end

  describe "#predefined" do
    it "returns hash of predefined superatoms" do
      expect(superatom.predefined).to be_a(Hash)
    end

    it "contains common superatoms" do
      known_superatoms = %i[Et tBu iPr CF3]
      known_superatoms.each do |sa|
        expect(superatom.predefined).to have_key(sa)
      end
    end

    it "maps superatom names to SMILES" do
      expect(superatom.predefined[:Et]).to eq("CC")
      expect(superatom.predefined[:tBu]).to eq("C(C)(C)C")
      expect(superatom.predefined[:CF3]).to eq("C(F)(F)F")
    end
  end

  describe "#custom" do
    it "returns hash of custom superatoms" do
      expect(superatom.custom).to be_a(Hash)
    end
  end

  describe "#get_superatom" do
    context "when superatom exists" do
      it "returns the SMILES for a known superatom" do
        result = superatom.get_superatom("Et")
        expect(result).to eq("CC")
      end

      it "returns SMILES for tBu" do
        result = superatom.get_superatom("tBu")
        expect(result).to eq("C(C)(C)C")
      end
    end

    context "when superatom does not exist" do
      it "returns empty string" do
        result = superatom.get_superatom("NONEXISTENT_SUPERATOM_XYZ123")
        expect(result).to eq("")
      end
    end

    context "with symbol input" do
      it "handles symbol keys" do
        result = superatom.get_superatom(:Et)
        expect(result).to eq("CC")
      end
    end
  end
end

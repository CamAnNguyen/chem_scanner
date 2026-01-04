# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::Interpreter::Reaction do
  let(:reaction) { described_class.new }

  describe "#initialize" do
    it "initializes with empty arrays for reactants, reagents, products" do
      expect(reaction.reactants).to eq([])
      expect(reaction.reagents).to eq([])
      expect(reaction.products).to eq([])
    end

    it "initializes with empty arrays for ids" do
      expect(reaction.reactant_ids).to eq([])
      expect(reaction.reagent_ids).to eq([])
      expect(reaction.product_ids).to eq([])
      expect(reaction.text_ids).to eq([])
    end

    it "initializes with empty strings for reaction info" do
      expect(reaction.description).to eq("")
      expect(reaction.temperature).to eq("")
      expect(reaction.yield).to eq("")
      expect(reaction.time).to eq("")
    end

    it "initializes with empty arrays for reagent_smiles and steps" do
      expect(reaction.reagent_smiles).to eq([])
      expect(reaction.steps).to eq([])
    end

    it "initializes details as OpenStruct" do
      expect(reaction.details).to be_a(OpenStruct)
    end
  end

  describe "#molecule_ids" do
    it "returns combination of reactant_ids and product_ids" do
      reaction.reactant_ids = [1, 2]
      reaction.product_ids = [3, 4]

      expect(reaction.molecule_ids).to eq([1, 2, 3, 4])
    end
  end

  describe "#all_ids" do
    it "returns combination of reagent_ids and molecule_ids" do
      reaction.reactant_ids = [1, 2]
      reaction.reagent_ids = [5]
      reaction.product_ids = [3, 4]

      expect(reaction.all_ids).to eq([5, 1, 2, 3, 4])
    end
  end

  describe "#delete_id" do
    before do
      reaction.reactant_ids = [1, 2, 3]
      reaction.reagent_ids = [4, 5]
      reaction.product_ids = [6, 7]
    end

    it "deletes id from reactant_ids if present" do
      reaction.delete_id(2)
      expect(reaction.reactant_ids).to eq([1, 3])
    end

    it "deletes id from reagent_ids if present" do
      reaction.delete_id(5)
      expect(reaction.reagent_ids).to eq([4])
    end

    it "deletes id from product_ids if present" do
      reaction.delete_id(6)
      expect(reaction.product_ids).to eq([7])
    end

    it "does nothing if id not found" do
      reaction.delete_id(99)
      expect(reaction.reactant_ids).to eq([1, 2, 3])
      expect(reaction.reagent_ids).to eq([4, 5])
      expect(reaction.product_ids).to eq([6, 7])
    end
  end

  describe "#replace_id" do
    before do
      reaction.reactant_ids = [1, 2]
      reaction.reagent_ids = [3]
      reaction.product_ids = [4, 5]
    end

    it "replaces old_id with new_id in reactant_ids" do
      reaction.replace_id(1, 10)
      expect(reaction.reactant_ids).to include(10)
      expect(reaction.reactant_ids).not_to include(1)
    end

    it "replaces old_id with new_id in reagent_ids" do
      reaction.replace_id(3, 30)
      expect(reaction.reagent_ids).to include(30)
      expect(reaction.reagent_ids).not_to include(3)
    end

    it "replaces old_id with new_id in product_ids" do
      reaction.replace_id(5, 50)
      expect(reaction.product_ids).to include(50)
      expect(reaction.product_ids).not_to include(5)
    end
  end

  describe "#reaction_smiles" do
    let(:reactant1) { double("Molecule", cano_smiles: "CC") }
    let(:reactant2) { double("Molecule", cano_smiles: "CCC") }
    let(:product) { double("Molecule", cano_smiles: "CCCC") }
    let(:reagent) { double("Molecule", cano_smiles: "O") }

    before do
      reaction.reactants = [reactant1, reactant2]
      reaction.products = [product]
      reaction.reagents = [reagent]
      reaction.reagent_smiles = ["[H][H]"]
    end

    it "returns reaction SMILES in format reactants>reagents>products" do
      result = reaction.reaction_smiles
      expect(result).to eq("CC.CCC>O.[H][H]>CCCC")
    end

    it "handles empty reagents" do
      reaction.reagents = []
      reaction.reagent_smiles = []
      result = reaction.reaction_smiles
      expect(result).to eq("CC.CCC>>CCCC")
    end

    it "handles empty reactants and products" do
      reaction.reactants = []
      reaction.products = []
      result = reaction.reaction_smiles
      expect(result).to eq(">O.[H][H]>")
    end
  end

  describe "#to_hash" do
    let(:reactant) do
      double("Molecule", cano_smiles: "CC",
                         to_hash: { id: 1, smiles: "CC", label: "", text: "" })
    end
    let(:product) do
      double("Molecule", cano_smiles: "CCC",
                         to_hash: { id: 2, smiles: "CCC", label: "", text: "" })
    end

    before do
      reaction.arrow_id = 100
      reaction.reactants = [reactant]
      reaction.products = [product]
      reaction.description = "Test reaction"
      reaction.temperature = "80C"
      reaction.yield = "95%"
      reaction.time = "2h"
      reaction.reagent_smiles = ["O"]
    end

    it "returns hash representation of reaction" do
      hash = reaction.to_hash
      expect(hash[:id]).to eq(100)
      expect(hash[:description]).to eq("Test reaction")
      expect(hash[:temperature]).to eq("80C")
      expect(hash[:yield]).to eq("95%")
      expect(hash[:time]).to eq("2h")
      expect(hash[:reagent_smiles]).to eq(["O"])
    end

    it "includes sorted reactants and products" do
      hash = reaction.to_hash
      expect(hash[:reactants]).to be_an(Array)
      expect(hash[:products]).to be_an(Array)
    end
  end

  describe "#status" do
    let(:arrow) { double("Arrow", cross: false, line_type: 0) }
    let(:product_normal) { double("Molecule", check_red: nil) }
    let(:product_red) { double("Molecule", check_red: true) }

    before do
      reaction.arrow = arrow
    end

    context "when arrow is crossed" do
      before { allow(arrow).to receive(:cross).and_return(true) }

      it "returns Failed" do
        expect(reaction.status).to eq("Failed")
      end
    end

    context "when arrow line_type is 1 (dashed)" do
      before { allow(arrow).to receive(:line_type).and_return(1) }

      it "returns Planned" do
        expect(reaction.status).to eq("Planned")
      end
    end

    context "when any product is red" do
      before do
        reaction.products = [product_normal, product_red]
      end

      it "returns Failed" do
        expect(reaction.status).to eq("Failed")
      end
    end

    context "when reaction is normal" do
      before do
        reaction.products = [product_normal]
      end

      it "returns Succesful" do
        expect(reaction.status).to eq("Succesful")
      end
    end
  end

  describe "#inspect" do
    let(:arrow) { double("Arrow", id: 123) }

    before do
      reaction.arrow = arrow
      reaction.reactant_ids = [1]
      reaction.product_ids = [2]
    end

    it "returns a string representation" do
      result = reaction.inspect
      expect(result).to include("#<Reaction:")
      expect(result).to include("id=123")
      expect(result).to include("reactant_ids=[1]")
      expect(result).to include("product_ids=[2]")
    end
  end
end

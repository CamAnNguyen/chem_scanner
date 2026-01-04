# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChemScanner::ConfigurationUtil do
  describe ".hash_downcase" do
    it "converts all hash keys to downcase" do
      input = { "ABC" => "value1", "DeF" => "value2" }
      result = described_class.hash_downcase(input)
      expect(result.keys).to eq(["abc", "def"])
    end

    it "preserves values" do
      input = { "ABC" => "VALUE1" }
      result = described_class.hash_downcase(input)
      expect(result["abc"]).to eq("VALUE1")
    end

    it "handles empty hash" do
      result = described_class.hash_downcase({})
      expect(result).to eq({})
    end

    it "handles symbol keys" do
      input = { ABC: "value1" }
      result = described_class.hash_downcase(input)
      expect(result[:abc]).to eq("value1")
    end
  end

  describe ".hash_to_lines" do
    it "converts hash to newline-separated lines" do
      input = { "key1" => "value1", "key2" => "value2" }
      result = described_class.hash_to_lines(input)
      expect(result).to include("key1 key1 value1")
      expect(result).to include("key2 key2 value2")
    end

    it "starts with empty line" do
      input = { "key" => "value" }
      result = described_class.hash_to_lines(input)
      expect(result).to start_with("\n")
    end

    it "handles empty hash" do
      result = described_class.hash_to_lines({})
      expect(result).to eq("")
    end
  end

  describe ".read_superatom" do
    let(:temp_file) { Tempfile.new(["superatom_test", ".txt"]) }

    after do
      temp_file.close
      temp_file.unlink
    end

    it "reads superatom file format" do
      temp_file.write("Et Et CC\ntBu tBu C(C)(C)C")
      temp_file.flush

      result = described_class.read_superatom(temp_file.path)
      expect(result[:Et]).to eq("CC")
      expect(result[:tBu]).to eq("C(C)(C)C")
    end

    it "handles both columns as keys" do
      temp_file.write("CO2Et EtO2C C(=O)OCC")
      temp_file.flush

      result = described_class.read_superatom(temp_file.path)
      expect(result[:CO2Et]).to eq("C(=O)OCC")
      expect(result[:EtO2C]).to eq("C(=O)OCC")
    end

    it "skips empty lines and continues parsing" do
      temp_file.write("Et Et CC\n\ntBu tBu C(C)(C)C")
      temp_file.flush

      result = described_class.read_superatom(temp_file.path)
      expect(result.key?(:Et)).to eq(true)
      expect(result.key?(:tBu)).to eq(true)
    end

    it "handles range parameter" do
      temp_file.write("Et Et CC\ntBu tBu C(C)(C)C\niPr iPr C(C)C")
      temp_file.flush

      result = described_class.read_superatom(temp_file.path, 0..1)
      expect(result.key?(:Et)).to eq(true)
      expect(result.key?(:tBu)).to eq(true)
      expect(result.key?(:iPr)).to eq(false)
    end
  end
end

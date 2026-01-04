# frozen_string_literal: true

require_relative "../lib/chem_scanner"
require "ole/storage"

# Test reading 1.cdx using ChemScanner::Cdx
# Note: 1.cdx is an OLE object extracted from a DOCX file
file_path = File.expand_path("1.cdx", __dir__)
puts "Reading: #{file_path}"

# Check file header to determine format
header = IO.binread(file_path, 8)
ole_signature = [0xD0, 0xCF, 0x11, 0xE0]

if header == "VjCD0100"
  # Raw CDX format - read directly
  puts "Format: Raw CDX"
  cdx = ChemScanner::Cdx.new
  success = cdx.read(file_path)
elsif header.bytes[0, 4] == ole_signature
  # OLE container - extract CONTENTS entry
  puts "Format: OLE container (ChemDraw embedded object)"

  ole = Ole::Storage.open(file_path)
  contents = ole.root["CONTENTS"]

  if contents.nil?
    puts "No CONTENTS entry found in OLE file"
    exit 1
  end

  cdx_content = contents.read
  ole.close

  if cdx_content[0, 8] != "VjCD0100"
    puts "CONTENTS is not valid CDX data"
    exit 1
  end

  puts "Extracted CDX data: #{cdx_content.size} bytes"

  cdx = ChemScanner::Cdx.new
  success = cdx.read(cdx_content, false)  # false = data, not path
else
  puts "Unknown file format: #{header.bytes[0, 4].inspect}"
  exit 1
end

if success
  puts "Successfully parsed CDX file"
  puts "Version: #{cdx.version}"
  puts ""

  puts "=== Molecules (#{cdx.molecules.count}) ==="
  cdx.molecules.each do |mol|
    hash = mol.to_hash
    puts "  ID: #{hash[:id]}"
    puts "  SMILES: #{hash[:smiles]}"
    puts "  Label: #{hash[:label]}" if hash[:label]
    puts "  Text: #{hash[:text]}" if hash[:text]
    puts ""
  end

  puts "=== Reactions (#{cdx.reactions.count}) ==="
  cdx.reactions.each do |reaction|
    hash = reaction.to_hash
    puts "  ID: #{hash[:id]}"
    puts "  Description: #{hash[:description]}" if hash[:description]
    puts "  Temperature: #{hash[:temperature]}" if hash[:temperature]
    puts "  Time: #{hash[:time]}" if hash[:time]
    puts "  Yield: #{hash[:yield]}" if hash[:yield]
    puts "  Reagent SMILES: #{hash[:reagent_smiles].join(', ')}" unless hash[:reagent_smiles].empty?
    puts ""

    puts "  Reactants:"
    hash[:reactants].each do |r|
      puts "    - #{r[:smiles]}"
    end

    puts "  Products:"
    hash[:products].each do |p|
      puts "    - #{p[:smiles]}"
    end
    puts ""
  end
else
  puts "Failed to parse CDX file"
end

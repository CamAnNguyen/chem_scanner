# frozen_string_literal: true

require_relative "../lib/chem_scanner"

# Test reading test_2.docx using ChemScanner::Docx
file_path = File.expand_path("test_2.docx", __dir__)
puts "Reading: #{file_path}"

parser = ChemScanner::Docx.new
success = parser.read(file_path)

if success
  puts "Successfully parsed DOCX file"
  puts ""

  puts "=== Molecules (#{parser.molecules.count}) ==="
  parser.molecules.each do |mol|
    hash = mol.to_hash
    puts "  ID: #{hash[:id]}"
    puts "  SMILES: #{hash[:smiles]}"
    puts "  Label: #{hash[:label]}" if hash[:label]
    puts "  Text: #{hash[:text]}" if hash[:text]
    puts ""
  end

  puts "=== Reactions (#{parser.reactions.count}) ==="
  parser.reactions.each do |reaction|
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

  puts "=== CDX Map (#{parser.cdx_map.count} entries) ==="
  parser.cdx_map.each do |key, value|
    puts "  #{key}:"
    puts "    Image format: #{value[:img_ext]}"
    puts "    Has image data: #{!value[:img_b64].nil?}"
  end
else
  puts "Failed to parse DOCX file"
end

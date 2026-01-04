#!/usr/bin/env ruby
require "bundler/setup"
require "chem_scanner"
require "json"

def generate_output(parser)
  reactions = parser.reactions.map(&:to_hash).sort_by { |r| r[:id] }
  molecules = parser.molecules.map(&:to_hash).sort_by { |r| r[:id] }
  reactions.empty? ? molecules : reactions
end

def stringify_keys(obj)
  case obj
  when Hash
    obj.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) }
  when Array
    obj.map { |v| stringify_keys(v) }
  else
    obj
  end
end

Dir["spec/cdx/*.cdx"].each do |file|
  filename = File.basename(file, ".cdx")
  puts "Processing CDX: #{filename}"

  cdx = ChemScanner::Cdx.new
  cdx.read(file)
  output = generate_output(cdx)

  json_path = "spec/json/#{filename}.json"
  File.write(json_path, JSON.pretty_generate(stringify_keys(output)))
end

Dir["spec/cdxml/*.cdxml"].each do |file|
  filename = File.basename(file, ".cdxml")
  puts "Processing CDXML: #{filename}"

  cdxml = ChemScanner::Cdxml.new
  cdxml.read(file)
  output = generate_output(cdxml)

  json_path = "spec/json/#{filename}.json"
  File.write(json_path, JSON.pretty_generate(stringify_keys(output)))
end

Dir["spec/doc/*.doc"].each do |file|
  filename = File.basename(file, ".doc")
  puts "Processing DOC: #{filename}"

  doc = ChemScanner::Doc.new
  doc.read(file)

  output = {}
  doc.cdx_map.each do |key, cdx|
    reactions = cdx.reactions.map(&:to_hash).sort_by { |r| r[:id] }
    output[key.to_s] = reactions
  end

  json_path = "spec/json/#{filename}_doc.json"
  File.write(json_path, JSON.pretty_generate(stringify_keys(output)))
end

Dir["spec/docx/*.docx"].each do |file|
  filename = File.basename(file, ".docx")
  puts "Processing DOCX: #{filename}"

  docx = ChemScanner::Docx.new
  docx.read(file)

  output = {}
  docx.cdx_map.each do |key, cdx_info|
    cdx = cdx_info[:cdx]
    reactions = cdx.reactions.map(&:to_hash).sort_by { |r| r[:id] }
    output[key.to_s] = reactions
  end

  json_path = "spec/json/#{filename}_docx.json"
  File.write(json_path, JSON.pretty_generate(stringify_keys(output)))
end

puts "Done regenerating fixtures!"

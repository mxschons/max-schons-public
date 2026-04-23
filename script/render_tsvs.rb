#!/usr/bin/env ruby
# Renders every .tsv in the repo as a Jekyll page with an HTML table.
# Runs before `jekyll build`. Writes to _tsv_pages/ (included via _config.yml).

require "csv"
require "fileutils"
require "cgi"

OUTPUT_DIR = "_tsv_pages"
REPO = "mxschons/max-schons-public"

FileUtils.rm_rf(OUTPUT_DIR)
FileUtils.mkdir_p(OUTPUT_DIR)

count = 0
Dir.glob("**/*.tsv").reject { |p| p.start_with?("_site/", "vendor/", "node_modules/") }.each do |tsv_path|
  rows = CSV.read(tsv_path, col_sep: "\t", headers: true, liberal_parsing: true)
  title = File.basename(tsv_path, ".tsv").split(/[-_]/).map(&:capitalize).join(" ")
  permalink = "/" + tsv_path.sub(/\.tsv$/, "/")

  out_path = File.join(OUTPUT_DIR, tsv_path.gsub("/", "__").sub(/\.tsv$/, ".html"))
  FileUtils.mkdir_p(File.dirname(out_path))

  File.open(out_path, "w") do |f|
    f.puts "---"
    f.puts "layout: page"
    f.puts "title: #{title}"
    f.puts "permalink: #{permalink}"
    f.puts "---"
    f.puts
    f.puts %(<p><a href="https://github.com/#{REPO}/blob/main/#{tsv_path}">View raw TSV on GitHub</a></p>)
    f.puts "<table>"
    f.puts "  <thead><tr>"
    rows.headers.each { |h| f.puts "    <th>#{CGI.escapeHTML(h.to_s)}</th>" }
    f.puts "  </tr></thead>"
    f.puts "  <tbody>"
    rows.each do |row|
      f.puts "    <tr>"
      row.fields.each { |v| f.puts "      <td>#{CGI.escapeHTML(v.to_s)}</td>" }
      f.puts "    </tr>"
    end
    f.puts "  </tbody>"
    f.puts "</table>"
  end
  count += 1
end

puts "Rendered #{count} TSV page(s)."

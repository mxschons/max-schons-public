#!/usr/bin/env ruby
# encoding: UTF-8
# Builds aggregated FAQ pages from all **/faq/*.md files.
# Runs before `jekyll build`. Writes to _faq_pages/ (included via _config.yml).
#
# Outputs:
#   _faq_pages/all.md            → permalink /faq/              (everything grouped by area)
#   _faq_pages/<area>.md         → permalink /<area>/faq/       (one area's FAQs)
#
# Each aggregate page also embeds FAQPage JSON-LD for search / AI crawlers.

require "fileutils"
require "json"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

OUTPUT_DIR = "_faq_pages"
FileUtils.rm_rf(OUTPUT_DIR)
FileUtils.mkdir_p(OUTPUT_DIR)

# Gather: { area => [absolute paths to faq files, sorted] }
faqs_by_area = Hash.new { |h, k| h[k] = [] }
Dir.glob("*/faq/*.md").reject { |p| p.start_with?("_site/", "vendor/") }.sort.each do |path|
  area = path.split("/").first
  faqs_by_area[area] << path
end

def read_body(path)
  # Strip leading H1 (it will become an H2 in the aggregate), return the rest.
  lines = File.readlines(path)
  until lines.empty? || lines.first.start_with?("# ")
    lines.shift
  end
  h1 = lines.shift&.sub(/^# /, "")&.strip
  # Drop any immediately-following blank lines.
  lines.shift while lines.first && lines.first.strip.empty?
  [h1, lines.join.rstrip]
end

def area_title(area)
  area.split("-").map(&:capitalize).join(" ")
end

def faq_jsonld(entries)
  # entries: [{ question:, answer_text: }, ...]
  jsonld = {
    "@context" => "https://schema.org",
    "@type" => "FAQPage",
    "mainEntity" => entries.map do |e|
      {
        "@type" => "Question",
        "name" => e[:question],
        "acceptedAnswer" => {
          "@type" => "Answer",
          "text" => e[:answer_text]
        }
      }
    end
  }
  "<script type=\"application/ld+json\">\n#{JSON.pretty_generate(jsonld)}\n</script>"
end

def plain_answer(body)
  # Strip markdown formatting for JSON-LD answer text. Keep it simple:
  # drop image refs, collapse whitespace, limit length.
  text = body.gsub(/!\[[^\]]*\]\([^)]*\)/, "") # images
             .gsub(/\[([^\]]+)\]\([^)]*\)/, '\1') # links → text
             .gsub(/[`*_>#]/, "")
             .gsub(/\s+/, " ")
             .strip
  text.length > 1500 ? text[0, 1497] + "..." : text
end

# Per-area aggregate pages.
faqs_by_area.each do |area, paths|
  entries = []
  out = File.join(OUTPUT_DIR, "#{area}.md")
  File.open(out, "w") do |f|
    f.puts "---"
    f.puts "layout: page"
    f.puts "title: #{area_title(area)} FAQ"
    f.puts "permalink: /#{area}/faq/"
    f.puts "---"
    f.puts
    f.puts "_Aggregated from individual files in [`#{area}/faq/`](https://github.com/mxschons/max-schons-public/tree/main/#{area}/faq)._"
    f.puts
    paths.each do |p|
      title, body = read_body(p)
      entries << { question: title, answer_text: plain_answer(body) }
      f.puts "## #{title}"
      f.puts
      f.puts body
      f.puts
    end
    f.puts
    f.puts faq_jsonld(entries)
  end
end

# Global aggregate page.
all_entries = []
out = File.join(OUTPUT_DIR, "all.md")
File.open(out, "w") do |f|
  f.puts "---"
  f.puts "layout: page"
  f.puts "title: All FAQs"
  f.puts "permalink: /faq/"
  f.puts "---"
  f.puts
  f.puts "_Aggregated from every `*/faq/*.md` file in the repo._"
  f.puts
  faqs_by_area.keys.sort.each do |area|
    f.puts "# #{area_title(area)}"
    f.puts
    faqs_by_area[area].each do |p|
      title, body = read_body(p)
      all_entries << { question: title, answer_text: plain_answer(body) }
      f.puts "## #{title}"
      f.puts
      f.puts body
      f.puts
    end
  end
  f.puts
  f.puts faq_jsonld(all_entries)
end

total = faqs_by_area.values.map(&:length).sum
puts "Rendered #{faqs_by_area.size} per-area FAQ page(s) + 1 global aggregate (#{total} entries) with FAQPage JSON-LD."

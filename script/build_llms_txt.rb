#!/usr/bin/env ruby
# encoding: UTF-8
# Generates /llms.txt (index) and /llms-full.txt (concatenated corpus)
# into _site/ following the llms.txt convention (https://llmstxt.org).
#
# Run AFTER `jekyll build`.

require "fileutils"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

SITE_DIR = "_site"
SITE_URL = "https://mxschons.github.io/max-schons-public"
SITE_TITLE = "Max Schons (public)"
SITE_TAGLINE = "Things worth sharing — FAQs, recommendations, lists, templates, checklists. CC0."

unless Dir.exist?(SITE_DIR)
  abort "ERROR: #{SITE_DIR}/ not found. Run `jekyll build` first."
end

SKIP_PREFIXES = %w[_site/ vendor/ _faq_pages/ _tsv_pages/ docs/].freeze
ALWAYS_SKIP = %w[README.md CHANGELOG.md index.md].freeze

def extract_h1(path)
  File.foreach(path) do |line|
    if line =~ /^#\s+(.+?)\s*$/
      return $1
    end
  end
  File.basename(path, ".md").split("-").map(&:capitalize).join(" ")
end

def last_modified(path)
  date = `git log -1 --format=%cs -- #{path.shellescape} 2>/dev/null`.strip
  date.empty? ? nil : date
end

def permalink_for(path)
  # Matches the _config.yml permalink pattern /:path/:basename and the
  # per-page overrides used by faq files.
  base = path.sub(/\.md$/, "")
  "/#{base}/"
end

def area_title(area)
  area.split("-").map(&:capitalize).join(" ")
end

# Collect pages grouped by life area (top-level folder).
pages_by_area = Hash.new { |h, k| h[k] = [] }
Dir.glob("**/*.md").sort.each do |path|
  next if SKIP_PREFIXES.any? { |p| path.start_with?(p) }
  next if ALWAYS_SKIP.include?(path)

  area = path.split("/").first
  title = extract_h1(path)
  link = SITE_URL + permalink_for(path)
  modified = last_modified(path)
  pages_by_area[area] << { path: path, title: title, link: link, modified: modified }
end

# --- llms.txt: short index (llmstxt.org spec) ---

llms_txt = +""
llms_txt << "# #{SITE_TITLE}\n\n"
llms_txt << "> #{SITE_TAGLINE}\n\n"
llms_txt << "This file is an index for LLMs. The full corpus is at #{SITE_URL}/llms-full.txt. "
llms_txt << "Each HTML page also has a raw markdown twin — append `.md` to any URL to get the source.\n\n"

pages_by_area.keys.sort.each do |area|
  llms_txt << "## #{area_title(area)}\n\n"
  pages_by_area[area].each do |p|
    llms_txt << "- [#{p[:title]}](#{p[:link]})"
    llms_txt << " — last modified #{p[:modified]}" if p[:modified]
    llms_txt << "\n"
  end
  llms_txt << "\n"
end

# Also include TSV-rendered pages.
tsv_paths = Dir.glob("**/*.tsv").reject { |p| SKIP_PREFIXES.any? { |pre| p.start_with?(pre) } }
if tsv_paths.any?
  llms_txt << "## Data tables\n\n"
  tsv_paths.sort.each do |p|
    title = File.basename(p, ".tsv").split(/[-_]/).map(&:capitalize).join(" ")
    link = SITE_URL + "/" + p.sub(/\.tsv$/, "/")
    modified = last_modified(p)
    llms_txt << "- [#{title}](#{link})"
    llms_txt << " — last modified #{modified}" if modified
    llms_txt << "\n"
  end
  llms_txt << "\n"
end

llms_txt << "## Aggregated pages\n\n"
llms_txt << "- [All FAQs](#{SITE_URL}/faq/)\n"
pages_by_area.keys.sort.each do |area|
  llms_txt << "- [#{area_title(area)} FAQ](#{SITE_URL}/#{area}/faq/)\n"
end

File.write(File.join(SITE_DIR, "llms.txt"), llms_txt)

# --- llms-full.txt: full corpus ---

llms_full = +""
llms_full << "# #{SITE_TITLE}\n\n"
llms_full << "> #{SITE_TAGLINE}\n\n"
llms_full << "Source: #{SITE_URL}. License: CC0 1.0.\n\n"
llms_full << "---\n\n"

pages_by_area.keys.sort.each do |area|
  llms_full << "# #{area_title(area)}\n\n"
  pages_by_area[area].each do |p|
    llms_full << "## #{p[:title]}\n\n"
    llms_full << "Source: #{p[:link]}"
    llms_full << " · Last modified: #{p[:modified]}" if p[:modified]
    llms_full << "\n\n"
    body = File.read(p[:path])
    # Strip the first H1 line since we already emitted its text above.
    body = body.sub(/\A#\s+.+?\n+/, "")
    llms_full << body.rstrip << "\n\n"
  end
end

if tsv_paths.any?
  llms_full << "# Data tables\n\n"
  tsv_paths.sort.each do |p|
    title = File.basename(p, ".tsv").split(/[-_]/).map(&:capitalize).join(" ")
    link = SITE_URL + "/" + p.sub(/\.tsv$/, "/")
    modified = last_modified(p)
    llms_full << "## #{title}\n\n"
    llms_full << "Source: #{link}"
    llms_full << " · Last modified: #{modified}" if modified
    llms_full << "\n\n"
    llms_full << "```tsv\n"
    llms_full << File.read(p).rstrip << "\n"
    llms_full << "```\n\n"
  end
end

File.write(File.join(SITE_DIR, "llms-full.txt"), llms_full)

puts "Wrote #{SITE_DIR}/llms.txt and #{SITE_DIR}/llms-full.txt (#{pages_by_area.values.map(&:size).sum} pages, #{tsv_paths.size} data tables)."

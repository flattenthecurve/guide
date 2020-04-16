# Run as `ruby import_language.rb es path/to/site.es.json`
require 'json'
require 'fileutils'
require 'ruby-lokalise-api'
require 'open-uri'
require 'zip'
require 'metadown'
require 'set'
require 'yaml'
require_relative '_plugins/common'

def language_dir(lang)
  "_sections/*/#{lang}"
end

SOURCE_LANG = "en"
SOURCE_DIR = language_dir(SOURCE_LANG)

SECTIONS_TO_FILES = {}
Dir["#{SOURCE_DIR}/**/*.md"].sort!.each { |filename|
  SECTIONS_TO_FILES[key_from_filename(filename)] = filename
}

TOP_LEVEL_PAGES = {}
Dir["*-en.md"].sort!.each { |filename|
  TOP_LEVEL_PAGES[key_from_top_level_file(filename)] = filename
}

STRINGS = YAML.load(File.open("_data/#{SOURCE_LANG}/strings.yml", 'r:UTF-8') { |f| f.read })

CONFIG_YML = File.open("_config.yml", 'r:UTF-8') { |f| f.read }
SUPPORTED_LANGS = YAML.load(CONFIG_YML)['languages']
NEW_LANGS = []

def generate_content(translations_lang, translations_file, no_review_keys=[])
  translations = JSON.parse(File.open(translations_file, 'r:UTF-8') { |f| f.read })

  FileUtils.rm_r(Dir[language_dir(translations_lang)], force: true)

  SECTIONS_TO_FILES.each do |section, source_file|
    translated_file = source_file.sub("/en/", "/#{translations_lang}/")
    translated_dir = File.dirname(translated_file)
    FileUtils.mkdir_p(translated_dir)
    File.open(translated_file, "w:UTF-8") { |file|
      content = translations[section]
      # At the moment, only add disclaimers to act_and_prepare
      if translated_dir =~ /act_and_prepare/ and no_review_keys.include? section
        # Insert disclaimer after the last h2 line.
        lines = content.lines
        last_hdr = lines.rindex{|e| e =~ /^##/}
        if last_hdr == nil
            last_hdr = 0
        else
            last_hdr = last_hdr + 1
        end
        lines.insert(last_hdr,
          "\n{:.disclaimer}\n",
          "{% include disclaimer/en/disclaimer.md %}\n\n")
        content = lines.join("")
      end
      file.puts content
    }
  end

  TOP_LEVEL_PAGES.each do |page, source_file|
    puts "source_file: #{source_file}"
    source_content = File.open(source_file, 'r:UTF-8') { |f| f.read }
    metadata = Metadown.render(source_content).metadata
    metadata["lang"] = translations_lang
    metadata["title"] = translations["#{page}-title"] if translations["#{page}-title"]
    translated_file = source_file.sub(/-en.md$/, "-#{translations_lang}.md")
    File.open(translated_file, "w:UTF-8") { |file|
      file.puts metadata.to_yaml
      file.puts "---\n"
      file.puts metadata["translate_content"] == false ? content_without_frontmatter(source_content) : translations[page]
    }
  end

  translated_strings_dir = "_data/#{translations_lang}"
  translated_strings = Hash[STRINGS.map { |key, value| [key, translations[key]] }]
  FileUtils.mkdir_p(translated_strings_dir)
  File.open("#{translated_strings_dir}/strings.yml", 'w:UTF-8') { |f| f.puts translated_strings.to_yaml }
  NEW_LANGS << translations_lang unless SUPPORTED_LANGS.include? translations_lang
end

LOKALISE_TOKEN = ARGV[0]
SINGLE_LANG = ARGV[1]
PROJECT_ID = "423383895e6b8c4b081a89.98184174"

puts "Building files from Lokalise"


def fetch_json_from_lokalise(lang: nil, filter_data: ['translated'])
    result = {}
    client = Lokalise.client LOKALISE_TOKEN
    resp = client.download_files(PROJECT_ID, {
        format: "json",
        filter_filename: ["pasted.json"],
        replace_breaks: false,
        placeholder_format: :icu,
        filter_data: filter_data}
    )
    if lang != nil:
        resp['filter_langs'] = [lang]
    # TODO: can this be replaced with plain Zip::File.open(resp["bundle_url"])
    Zip::File.open_buffer(open(resp["bundle_url"])) do |zip|
        zip.each do |entry|
            next unless entry.name.end_with?("pasted.json")
            file_lang = entry.name.split("/")[0]
            result[file_lang] = JSON.parse(entry.get_input_stream.read)
        end
    end
end

def keys_without_reviews(everything, reviewed):
    everything.keys.to_set - reviewed.keys.to_set
end

translations = fetch_json_from_lokalise(lang: SINGLE_LANG)
reviews = fetch_json_from_lokalise(lang: SINGLE_LANG, filter_data: 

def update_all_translations()
    client = Lokalise.client LOKALISE_TOKEN
    response = client.download_files(PROJECT_ID, {format: "json", filter_filenames: ["pasted.json"], replace_breaks: false, placeholder_format: :icu})

    puts "Downloading #{response["bundle_url"]} ..."
    content = open(response["bundle_url"])
    Zip::File.open_buffer(content) do |zip|
      zip.each do |entry|
        next unless entry.name.end_with?("pasted.json")
        next if entry.name.end_with?("#{SOURCE_LANG}/pasted.json")
        lang = entry.name.split("/")[0]
        next if SINGLE_LANG != nil && lang != SINGLE_LANG
        dest = "_translations/#{lang}.json"
        puts "Saving #{dest}"
        entry.extract(dest) { true }

        puts "Expanding .md"
        generate_content(lang, dest)

      end
    end
end

if SINGLE_LANG != nil
    # TODO: Lokalise fetches are suboptimal, 3 fetches are happening now.
    j = fetch_json_from_lokalise(SINGLE_LANG)
    no_reviews = keys_without_review(SINGLE_LANG)

    # Dump translation strings to json, because that's where we read them from.
    dest = "_translations/#{SINGLE_LANG}.json"
    File.open(dest, "w") do |f|
        f.write(j.to_json)
    end
    generate_content(SINGLE_LANG, dest, no_reviews)
# else
    # update_all_translations
    # TODO: Iterate over all lang, dest pairs 
    # generate_content(lang, dest)
end

unless NEW_LANGS.empty?
  puts "Langs to add: #{NEW_LANGS}"
  languages_regex = /^languages: (\[.*\])$/
  if CONFIG_YML =~ languages_regex
    new_languages_line = "languages: #{(SUPPORTED_LANGS + NEW_LANGS).to_s}"
    NEW_CONFIG_YML = CONFIG_YML.sub languages_regex, new_languages_line
    File.open('_config.yml', 'w:UTF-8') { |f| f.puts NEW_CONFIG_YML }
  end
end

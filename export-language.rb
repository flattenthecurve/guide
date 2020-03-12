require 'yaml'
require 'json'

def key_from_filename(name)
    basename = File.basename(name)
    if basename =~ /\d\d-(.*)\.md/
        return $1
    else
        raise "#{basename} doesn't match the \"99-some-file-name.md\" name format (in #{name})"
    end
end

texts = {}
YAML.load_file("_data/sections.yaml").each { |file|
    key = key_from_filename(file)
    content = File.open(file, 'r:UTF-8') { |f| f.read }
    texts[key] = content
}

puts texts.to_json

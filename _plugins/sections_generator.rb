module SectionsGenerator
  class Generator < Jekyll::Generator
    def generate(site)
      site.data['sections'] = {}
      site.data['toc'] = {}

      site.languages.each do |lang|
        dir = "_include/#{lang}"
        site.data['sections'][lang] = Dir["#{dir}/**/*.md"].sort!

        full_md_content = StringIO.new
        site.data['sections'][lang].each do |file|
          key = key_from_filename(file)
          content = File.open(file, 'r:UTF-8') { |f| f.read }
          full_md_content << content
          full_md_content << "\n\n"
        end

        md_converter = site.find_converter_instance(Jekyll::Converters::Markdown)
        full_html_content = md_converter.convert(full_md_content.string)
        toc = Jekyll::TableOfContents::Parser.new(full_html_content).build_toc
        site.data['toc'][lang] = toc
      end
    end
  end
end

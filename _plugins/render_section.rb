class RenderSectionTag < Liquid::Tag
  INCLUDE_TEMPLATE = Liquid::Template.parse("{% include_relative {{section_file_path}} %}")

  def initialize(tag_name, text, tokens)
    super
    @dir = text.strip
  end

  def render(context)
    site = context.registers[:site]
    lang = site.active_lang
    files = Dir["_sections/#{@dir}/#{lang}/**/*.md"].sort!
    content = StringIO.new

    files.each do |file|
      file_content = File.open(file, 'r:UTF-8') { |f| f.read }
      site.data['section_content'] ||= {}
      site.data['section_content'][key_from_filename(file)] = file_content

      context.stack do
        context['section_file_path'] = file
        content << INCLUDE_TEMPLATE.render(context)
      end
      content << "\n\n"
    end

    content.string
  end
end

Liquid::Template.register_tag('render_section', RenderSectionTag)

module Reading
  class Generator < Jekyll::Generator
    def generate(site)
      dir = "en"
      site.data['sections'] = Dir["#{dir}/**/*.md"].sort!
    end
  end
end

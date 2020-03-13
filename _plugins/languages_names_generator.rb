require "i18n_data"

module LanguagesNamesGenerator
  class Generator < Jekyll::Generator
    def generate(site)
      lang_name = {}
      site.languages.each do |lang|
        name = I18nData.languages(lang.upcase)[lang.upcase].split(";").first rescue lang
        lang_name[lang] = name
      end

      site.data['lang_name'] = lang_name
    end

    def priority
      :lowest
    end
  end
end

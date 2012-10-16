# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "mailchimp_fu"
  s.summary = "Mailchimp integration library for rails."
  s.description = "This gem allows you to copy your static assets to include a unique hash in their filename. By using this and modifying your Rails asset path you can easily enable your Rails application to serve static content using CloudFront with a custom origin policy."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.2"
  s.author = "Donald Piret"
  s.email = "donald@donaldpiret.com"
  s.homepage = "http://donaldpiret.com"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gibbon>, [">= 0.3.5"])
    else
      s.add_dependency(%q<gibbon>, [">= 0.3.5"])
    end
  else
    s.add_dependency(%q<gibbon>, [">= 0.3.5"])
  end
  
  s.add_development_dependency "rspec", ">= 2.6.3"
  s.add_development_dependency "rails", ">= 3.0.10"
  #s.add_development_dependency "capybara"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "debugger"
  s.add_development_dependency "delayed_job"
  s.add_development_dependency "database_cleaner"
  #s.add_development_dependency "webmock", ">= 1.7.0"
  #s.add_development_dependency "savon_spec", ">= 0.1.6"
  #s.add_development_dependency "vcr"
end
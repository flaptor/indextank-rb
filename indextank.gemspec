# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{indextank}
  s.version = "1.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Santiago Perez", "Terence Lee", "Diego Buthay"]
  s.date = %q{2011-04-04}
  s.description = %q{Ruby Client for the IndexTank API}
  s.email = ["santip@santip.com.ar", "hone02@gmail.com", "dbuthay@gmail.com"]
  s.files = ["lib/indextank.rb", "lib/indextank/client.rb", "lib/indextank/document.rb", "lib/indextank/exceptions.rb", "lib/indextank/function.rb", "lib/indextank/index.rb", "spec/lib/indextank/client_spec.rb", "spec/lib/indextank/document_spec.rb", "spec/lib/indextank/function_spec.rb", "spec/lib/indextank/index_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://www.indextank.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{nowarning}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby Client for the IndexTank API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jeweler>, [">= 1.4.0"])
      s.add_development_dependency(%q<rspec-core>, [">= 2.0.0.beta.19"])
      s.add_development_dependency(%q<rspec-expectations>, [">= 2.0.0.beta.19"])
      s.add_development_dependency(%q<rr>, [">= 0.10.11"])
      s.add_development_dependency(%q<rake>, [">= 0.8.7"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<parka>, [">= 0.3.1"])
      s.add_runtime_dependency(%q<faraday-stack>, [">= 0.1.5"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0.7.7"])
    else
      s.add_dependency(%q<jeweler>, [">= 1.4.0"])
      s.add_dependency(%q<rspec-core>, [">= 2.0.0.beta.19"])
      s.add_dependency(%q<rspec-expectations>, [">= 2.0.0.beta.19"])
      s.add_dependency(%q<rr>, [">= 0.10.11"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<parka>, [">= 0.3.1"])
      s.add_dependency(%q<faraday-stack>, [">= 0.1.5"])
      s.add_dependency(%q<yajl-ruby>, [">= 0.7.7"])
    end
  else
    s.add_dependency(%q<jeweler>, [">= 1.4.0"])
    s.add_dependency(%q<rspec-core>, [">= 2.0.0.beta.19"])
    s.add_dependency(%q<rspec-expectations>, [">= 2.0.0.beta.19"])
    s.add_dependency(%q<rr>, [">= 0.10.11"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<parka>, [">= 0.3.1"])
    s.add_dependency(%q<faraday-stack>, [">= 0.1.5"])
    s.add_dependency(%q<yajl-ruby>, [">= 0.7.7"])
  end
end

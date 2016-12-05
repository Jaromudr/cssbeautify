$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'cssbeautify'
  s.version     = '0.0.1'
  s.date        = Date.today.to_s
  s.summary     = "CssBeautify"
  s.description = "Beautify and format you css"
  s.authors     = ["Volodymyr Myskov"]
  s.email       = 'jaromudr@gmail.com'
  s.homepage    = "https://github.com/Jaromudr/cssbeautify"

  s.files       = Dir["lib/**/*"]
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec')
end
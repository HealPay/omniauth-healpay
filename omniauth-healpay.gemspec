# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name     = 'omniauth-healpay'
  s.version  = '0.0.1'
  s.authors  = ['Lance Carlson']
  s.email    = ['lcarlson@healpay.com']
  s.summary  = 'Healpay strategy for OmniAuth'
  s.homepage = 'https://github.com/healpay/omniauth-healpay'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'omniauth-oauth2', '~> 1.0.0'

  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'rake'
end

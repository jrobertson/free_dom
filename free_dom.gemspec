Gem::Specification.new do |s|
  s.name = 'free_dom'
  s.version = '0.2.1'
  s.summary = 'Dynamically builds a DOM from XML.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/free_dom.rb']
  s.add_runtime_dependency('domle', '~> 0.3', '>=0.3.1')
  s.signing_key = '../privatekeys/free_dom.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/free_dom'
end

class ApplicationMailbox < ActionMailbox::Base
  routing /.*/ => :test
end

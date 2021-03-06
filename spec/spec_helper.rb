require 'rubygems'
require 'spec'

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'couch_potato'

CouchPotato::Config.database_name = 'couch_potato_test'


class Comment
  include CouchPotato::Persistence

  validates_presence_of :title

  property :title
end

class Child
  include CouchPotato::Persistence
  
  property :text
end

def recreate_db
  CouchPotato.couchrest_database.delete! rescue nil
  CouchPotato.couchrest_database.server.create_db CouchPotato::Config.database_name
end
recreate_db

Spec::Matchers.define :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end

# Tests should pass without Rails.
class Hash
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
  
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end
end

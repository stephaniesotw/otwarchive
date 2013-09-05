class ArchiveImport < ActiveRecord::Base
  has_many :users
  has_many :collections
  has_many :email_templates
  attr_accessor :old_url_link
  attr_accessor :new_url_link
  attr_accessor :archivist_link

  # @return [Object]
  def initialize

  end

  def build_links()
    @old_url_link = "<a href=\"http://#{self.old_base_url}>#{self.name}</a>"
    @old_url_link = "<a href=\"http://#{self.new_url}>#{self.name} - at Ao3</a>"
    u = User.find(self.archivist_id)
    @archivist_link = "<a href=\"mailto://#{u.email}>#{u.login}</a>"
  end
end
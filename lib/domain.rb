class Domain
  def self.matches?(request)
    request.domain.present? && request.domain != "archiveofourown.org" && request.domain != "archiveofourown.com" && request.domain !="ao3.org" && request.domain != "stephanies.archiveofourown.org" && request.domain != "www.archiveofourown.org"
  end
end
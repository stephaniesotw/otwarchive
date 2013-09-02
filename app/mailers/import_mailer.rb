class ImportMailer < BulletproofMailer::Base
  include Resque::Mailer # see README in this directory
  include AuthlogicHelpersForMailers # otherwise any logged_in? checks in views will choke and die! :)
  include HtmlCleaner

  layout 'mailer'

  helper_method :current_user
  helper_method :current_admin
  helper_method :logged_in?
  helper_method :logged_in_as_admin?

  helper :application
  helper :tags
  helper :works
  helper :users
  helper :date
  helper :series

  default :from => ArchiveConfig.RETURN_ADDRESS

  # Sends an invitation to join the archive
  # Must be sent synchronously as it is rescued
  # TODO refactor to make it asynchronous
  def invitation(invitation_id)
    @invitation = Invitation.find(invitation_id)
    @user_name = (@invitation.creator.is_a?(User) ? @invitation.creator.login : '')
    mail(
      :to => @invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation"
    )
  end


  def parse_template(user,template_id,archive_id)
    template = EmailTemplate.find(template_id)
    archive =ArchiveImport.find(archive_id)
    archive.build_links()
    newbody = substitute_import_values(user,template,archive)
    return newbody
  end

  def substitute_import_values(user, template, archive)
    user.generate_password_update
    user.save!

    body = content.gsub("<!ArchivistEmailLink>", archive.archivist_link)
    body = content.gsub("<!ImportedArchive>", archive.name )
    body = content.gsub("<!penname>", user.login)
    body = content.gsub("<!TempPassword>", user.activation_code)
    body = content.gsub("<!ArchiveName>", "Archive of Our Own")
    body = content.gsub("<!ImportedWorks>","")
    body = content.gsub("<!NewPseud>", "ImportedPseud")
    body = content.gsub("<!OldLink>",archive.old_url_link)
    body = content.gsub("<!NewCollectionLink",archive.new_url_link)
    return body
  end

  def send_import_notifications(source_archive_id,existing)
    if existing == 1
      #TODO Convert pseudo code to actual code
      #get existing_template_id for the archive_id specified
      #parse template
      #send
    else
      #TODO Convert pseudo code to actual code
      #get new_template_id for the archive_id specified
      #parse template
      #send
    end
  end

  # Sends an invitation to join the archive and claim stories that have been imported as part of a bulk import
  def invitation_to_claim(invitation_id, archivist_login)
    @invitation = Invitation.find(invitation_id)
    @external_author = @invitation.external_author
    @archivist = archivist_login || "An archivist"
    @token = @invitation.token
    mail(
      :to => @invitation.invitee_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Invitation To Claim Stories"
    )
  end

  # Notifies a writer that their imported works have been claimed
  def claim_notification(external_author_id, claimed_work_ids)
    external_author = ExternalAuthor.find(external_author_id)
    @external_email = external_author.email
    @claimed_works = Work.where(:id => claimed_work_ids)
    mail(
      :to => external_author.user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Stories Uploaded"
    )
  end

  # Sends an admin message to a user
  def archive_notification(admin_login, user_id, subject, message)
    @user = User.find(user_id)
    @message = message
    @admin_login = admin_login
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Message #{subject}"
    )
  end

  # Asks a user to validate and activate their new account
  def signup_notification(user_id)
    @user = User.find(user_id)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Confirmation"
    )
  end

  # Emails a user to confirm that their account is validated and activated
  def activation(user_id)
    @user = User.find(user_id)
    mail(
      :to => @user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Your account has been activated."
    )
  end

	  # Confirms to a user that their email was changed
  def change_email(user_id, old_email, new_email)
    @user = User.find(user_id)
		@old_email= old_email
		@new_email= new_email
    mail(
      :to => @old_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Email changed"
    )
  end

  # Sends email to coauthors when a work is edited
  # NOTE: this must be sent synchronously! otherwise the new version will be sent.
  # TODO refactor to make it asynchronous by passing the content in the method
  def edit_work_notification(user, work)
    @user = user
    @work = work
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Your story has been updated"
    )
  end

end

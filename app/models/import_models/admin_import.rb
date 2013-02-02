class AdminImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Translation

  attr_accessor :import_name
  attr_accessor :create_archive_record
  attr_accessor :source_type
  attr_accessor :database_username
  attr_accessor :database_password
  attr_accessor :database_host
  attr_accessor :database_name
  attr_accessor :temp_table_prefix
  attr_accessor :source_table_prefix
  attr_accessor :import_fandom
  attr_accessor :source_warning_class
  attr_accessor :create_collection
  attr_accessor :new_collection_id
  attr_accessor :new_collection_owner
  attr_accessor :new_collection_title
  attr_accessor :new_collection_name
  attr_accessor :new_collection_description
  attr_accessor :categories_as_collections
  attr_accessor :import_reviews
  attr_accessor :notify_imported_users
  attr_accessor :existing_notification_message
  attr_accessor :new_notification_message
  # To change this template use File | Settings | File Templates.
end
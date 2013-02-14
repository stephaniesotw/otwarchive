class MassImportTool
    require "mysql"


    def initialize()
      #Import Class Version Number
      @version = 1
      #################################################
      #Database Settings
      ###############################################
      #sql_filename
      @sql_filename = "rescued_archive.sql"
      
      #Database Host Address (localhost)
      @database_host = "localhost"

      #Database Username (funnyuser)
      @database_username = "stephanies"

      #Database Password (password)
      @database_password = "Trustno1"

      #database name
      @database_name = "stephanies_development"

      #temporary table prefix to be added to table names during import
      @temptableprefix = ""
      
      #NOTE! change to nil for final version, as there will be no default
      @connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
      #####################################################

      @archivist_login = "StephanieTest"
      @archivist_password = "password"
      @archivist_email = "stephaniesmithstl@gmail.com"

      #Match Existing Authors by Email-Address
      @match_existing_authors = true

      #Import Job Name
      @import_name = "New Import"
      @import_fandom = "Harry Potter"

      #Create record for imported archive (false if already exists)
      @create_import_archive_record = true

      #will error if not unique, just let it create it and assign it if you are unsure
      #Import Archive ID
      @import_archive_id = 100

      #Import reviews t/f
      @import_reviews = true


      #import categories as subcollections, if false, they will be converted to freeform tags
      @categories_as_subcollections = true

      @categories_as_tags = false
      #Message Values
      ####################################
      ##If true, send invites unconditionaly,
      # if false add them to the que to be sent when it gets to it, could be delayed.
      @bypass_invite_que = true

      #Send notification email with invitation to archive to imported users
      @notify_imported_users = true

      #Send message for each work imported? (or 1 message for all works)
      @send_individual_messages = false

      @new_user_email_id = 0
      @new_user_notice_id = 0
      @existing_user_email_id = 0
      @existing_user_notice_id = 0

      #New Collection Values
      #####################################
      #ID Of the newly created collection, filled with value automatically if create collection is true
      @new_collection_id = 123456789

      #Create collection for imported works?
      @create_collection = true

      #Owner for created collection
      @new_collection_owner = "Stephanie"

      @new_collection_owner_pseud = "1010"

      @new_collection_title = "Imported Archive Name"


      @new_collection_name = "shortname"

      #New Collection Description
      @new_collection_description = "Something here"

      #=========================================================
      #Destination Options / Settings
      #=========================================================
      @new_url  = ""

      @archivist_user_id = 0

      #If using ao3 cats, sort or skip
      @SortForAo3Categories = true

      #Import categories as categories or use ao3 cats
      @use_proper_categories = false

      #Destination otwarchive Ratings (1 being NR if NR Is conservative, 5 if not)
      #NR
      @target_rating_1 = 9

      #general audiences
      @target_rating_2 = 10

      #teen
      @target_rating_3 = 11

      #Mature
      @target_rating_4 = 12

      #Explicit
      @target_rating_5 = 13

      #========================
      #Source Variables
      #========================
      @source_base_url = ""


      #Source Archive Type
      @source_archive_type = 3

      #If archivetype being imported is efiction 3 >  then specify what class holds warning information
      @source_warning_class_id = 1

      #Holds Value for source table prefix
      @source_table_prefix = "fanfiction_"

      ################# Self Defined based on above
      #Source Ratings Table
      @source_ratings_table = nil

      #Source Users Table
      @source_users_table = nil

      #Source Stories Table
      @source_stories_table = nil

      #Source Reviews Table
      @source_reviews_table = nil

      #Source Chapters Table
      @source_chapters_table = nil

      #Source Characters Table
      @source_characters_table = nil

      #Source Subcategories Table
      @source_subcatagories_table = nil

      #Source Categories Table
      @source_categories_table = nil

      #string holder
      @get_author_from_source_query = nil

      #############
      #debug stuff
      @debug_update_source_tags = true
      #Skip Rating Transformation (ie if import in progress or testing)
      @skip_rating_transform = false
    end


    #get all possible tags from source
    def get_tag_list(tl, at)
      taglist = tl


      case at
        #storyline
        when 4
          #categories
          r = @connection.query("Select caid, caname from #{@source_category_table_prefix}; ")
          r.each do |r1|
            nt = ImportTag.new()
            nt.tag_type = "category"
            nt.old_id = r1[0]
            nt.tag = r1[1]
            taglist.push(nt)
          end
          #subcategories
          rr = @connection.query("Select subid, subname from #{@source_subcategories_table}; ")
          unless rr.num_rows.nil? || rr.num_rows == 0
            rr.each do |r2|
              nt = ImportTag.new()
              nt.tag_type = 99
              nt.old_id = r2[0]
              nt.tag = r2[1]
              taglist.push(nt)
            end
          end

        #efiction 3
        when 3
          #classes
          r = @connection.query("Select class_id, class_type, class_name from #{@source_classes_table}; ")
          r.each do |r1|
            nt = ImportTag.new()
            if r1[1] == @source_warning_class_id
              nt.tag_type = 6
            else
              nt.tag_type = "freeform"
            end
            nt.old_id = r1[0]
            nt.tag = r1[2]
            taglist.push(nt)
          end
          #categories
          rr = @connection.query("Select catid, category from #{@source_categories_table}; ")
          rr.each do |r2|
            nt = ImportTag.new()
            nt.tag_type = "category"
            nt.old_id = r2[0]
            nt.tag = r2[1]
            taglist.push(nt)
          end
          #characters
          rrr = @connection.query("Select charid, charname from #{@source_characters_table}; ")
          rrr.each do |r3|
            nt = ImportTag.new()
            nt.tag_type = "character"
            nt.old_id = r3[0]
            nt.tag = r3[1]
            taglist.push(nt)
          end
        when 2
           #categories
          rr = @connection.query("Select catid, category from #{@source_categories_table}; ")
          rr.each do |r2|
            nt = ImportTag.new()
            nt.tag_type = "category"
            nt.old_id = r2[0]
            nt.tag = r2[1]
            taglist.push(nt)
          end
          #characters
          rrr = @connection.query("Select charid, charname from #{@source_characters_table}; ")
          rrr.each do |r3|
            nt = ImportTag.new()
            nt.tag_type = "character"
            nt.old_id = r3[0]
            nt.tag = r3[1]
            taglist.push(nt)
          end
      end

      return taglist
    end

    #ensure all source tags exist in target in some form
    def fill_tag_list(tl)
      i = 0
        temptag = tl[i]
      escaped_tag_name = Mysql.escape_string(temptag.tag)


        r = @connection.query("Select id from tags where name = '#{escaped_tag_name}'; ")

        ##if not found add tag
        if !temptag.tag_type == "category" || 99
          if r.num_rows == 0 then
            # '' self.update_record_target("Insert into tags (name, type) values ('#{temptag.tag}','#{temptag.tag_type}');")
            temp_new_tag = Tag.new()
            temp_new_tag.type = "#{temptag.tag_type}"
            temp_new_tag.name = "#{temptag.tag}"
            temp_new_tag.save

            temptag.new_id = temp_new_tag.id
          else
            r.each do |r|
              temptag.new_id = r[0]
            end
          end
        else
          if @categories_as_tags == true
            if r.num_rows == 0 then
              # '' self.update_record_target("Insert into tags (name, type) values ('#{temptag.tag}','#{temptag.tag_type}');")
              temp_new_tag = Tag.new()
              temp_new_tag.type = "freeform"
              temp_new_tag.name = "#{temptag.tag}"
              temp_new_tag.save

              temptag.new_id = temp_new_tag.id
            else
              r.each do |r|
                temptag.new_id = r[0]
              end
            end
          end


        end


        #return importtag object with new id and its corresponding data ie old id and tag to array
        tl[i] = temptag
        i = i + 1
      end
      return tl
    end

    def create_child_collection(name, parent_id, description, title)
      collection = Collection.new(
          name: name,
          description: description,
          title: title,
          parent_id: parent_id
      )
      user = User.find(@archivist_user_id)
      collection.collection_participants.build(
          pseud: user.default_pseud,
          participant_role: "Owner"
      )
      collection.save
      return collection.id
    end

    #Convert Categories To Collections
    def convert_categories_to_collections(level)
      case level
        when 0
          case @source_archive_type
            when 3

              rr = @connection.query("Select catid,parentcatid,category,description from #{@source_categories_table} where parentcatid = -1")


              rr.each do |r3|
                ic = ImportCategory.new
                ic.category_name=r3[2].gsub(/\s+/, "")
                ic.new_id=
                    ic.old_id=r3[0]
                ic.new_parent_id=@new_collection_id
                ic.old_parent_id=r3[1]
                ic.title=r3[2]
                ic.description=r3[3]
                if ic.description == nil then
                  ic.description = ""
                end
                puts "old parent #{ic.old_parent_id}"
puts "new parent #{ic.new_parent_id}"
                ic.new_id= create_child_collection(ic.category_name,ic.new_parent_id,ic.description,ic.title)
                nci = CollectionImport.new
                nci.old_id = ic.old_id
                nci.new_id = ic.new_id
                nci.source_archive_id = @import_archive_id
                nci.save!
              end
              convert_categories_to_collections(1)
            when 4
          end
        else
          case @source_archive_type
            when 3

              rr = @connection.query("Select catid,parentcatid,category,description from #{@source_categories_table} where parentcatid > 0")


              rr.each do |r3|
                ic = ImportCategory.new
                ic.category_name=r3[2].gsub(/\s+/, "")
                ic.new_id=
                    ic.old_id=r3[0]

                ic.old_parent_id=r3[1]
                ic.title=r3[2]
                ic.description=r3[3]
                if ic.description == nil then
                  ic.description = ""
                end
                puts "old parent #{ic.old_parent_id}"



                ic.new_parent_id = get_single_value_target("Select new_id from collection_imports where old_id = #{ic.old_parent_id} and source_archive_id = #{@import_archive_id}")
                  puts "new parent #{ic.new_parent_id}"


                ic.new_id= create_child_collection(ic.category_name,ic.new_parent_id,ic.description,ic.title)
                nci = CollectionImport.new
                nci.old_id = ic.old_id
                nci.new_id = ic.new_id
                nci.source_archive_id = @import_archive_id
                nci.save!
              end
            when 4
          end

        end



    end


    def create_import_record
      update_record_target("insert into archive_imports (name,archive_type_id,old_base_url,associated_collection_id,new_user_notice_id,existing_user_notice_id,existing_user_email_id,new_user_email_id,new_url,archivist_user_id)  values ('#{@import_name}',#{@source_archive_type},'#{
@source_base_url}',#{@new_collection_id},#{@new_user_notice_id},#{@existing_user_notice_id},#{@new_user_email_id},#{@existing_user_email_id},'#{@new_url}',#{@archivist_user_id})")
    end

    ##################################################################################################
    # Main Worker Sub

    def import_data()

      puts " Setting Import Values "
      self.set_import_strings()
      #create collection & archivist
      self.create_archivist_and_collection


      #create import record
       create_import_record

      #Update Tags and get Taglist
      puts "Updating Tags"
      tag_list = Array.new()

      #create list of all tags used in source
      tag_list = get_tag_list(tag_list,@source_archive_type)

      #check for tag existance on target archive
      tag_list = self.fill_tag_list(tag_list)

      #pull source stories

      r = @connection.query("SELECT * FROM #{@source_stories_table} ;")

      puts "Importing Stories"
      i = 0
      r.each do |row|
        puts " Importing Story #{i}"
        #create new ImportWork Object
        ns = ImportWork.new()
        #create new importuser object
        a = ImportUser.new()
        #Create Taglisit for this story
        my_tag_list = Array.new()
        begin
          case @source_archive_type
            #storyline
            when 4
              ns.source_archive_id = @import_archive_id
              ns.old_work_id = row[0]
              puts ns.old_work_id

              ns.title = row[1]
              #debug info
              puts ns.title
              ns.summary = row[2]
              ns.old_user_id = row[3]
              ns.rating_integer = row[4]
              rating_tag = ImportTag.new()
              rating_tag.tag_type = 7
              rating_tag.new_id = ns.rating_integer
              my_tag_list.push(rating_tag)
              ns.published =  row[5]
              cattag = ImportTag.new()
              if @use_proper_categories == true
                cattag.tag_type = 1
              else
                cattag.tag_type = 3
              end
              cattag.new_id = row[6]
              my_tag_list.push(cattag)
              subcattag = ImportTag.new()
              if @use_proper_categories == true
                subcattag.tag_type = 1
              else
                subcattag.tag_type = 3
              end
              subcattag.new_id =row[11]
              my_tag_list.push(subcattag)
              ns.updated = row[9]
              ns.completed = row[12]
              ns.hits = row[10]
            #efiction 3
            when 3
              ns.old_work_id = row[0]
              ns.title = row[1]
              ns.summary = row[2]
              ns.old_user_id = row[10]
              ns.classes = row[5]
              ns.categories = row[4]
              ns.characters = [6]
              ns.rating_integer = row[7]
              rating_tag = ImportTag.new()
              rating_tag.tag_type =7
              rating_tag.new_id = ns.rating_integer
              tag_list.push(rating_tag)
              ns.published = row[8]
              ns.updated = row[9]
              ns.completed = row[14]
              ns.hits = row[18]
              if !@source_warning_class_id == nil

              end
              my_tag_list = get_work_class_tags(my_tag_list,ns.classes,"classes")
              my_tag_list = get_work_class_tags(my_tag_list,ns.characters,"characters")
                         #

          end
          #debug info
          puts "attempting to get new user id, user: #{ns.old_user_id}, source: #{ns.source_archive_id}"

          a = ImportUser.new
          #see if user / author exists for this import already
          ns.new_user_id = self.get_new_user_id_from_imported(ns.old_user_id, @import_archive_id)
          puts "The New user id!!!! ie value at this point #{ns.new_user_id}"

          ##get import user object from source database
          a = self.get_import_user_object_from_source(ns.old_user_id)
          if ns.new_user_id == 0
            puts "didnt exist in this import"
            #see if user account exists in main archive by checking email,
            temp_author_id = get_user_id_from_email(a.email)

            if temp_author_id == 0 then
              #if not exist , add new user with user object, passing old author object
              new_a = ImportUser.new
              new_a = self.add_user(a)

              #pass values to new story object
              ns.penname = new_a.penname
              ns.new_user_id = new_a.new_user_id

              #debug info
              puts "newu 1"
              puts "newid = #{new_a.new_user_id}"

              #get newly created pseud id
              new_pseud_id = get_default_pseud_id(ns.new_user_id)

              #set the penname on newly created pseud to proper value
              update_record_target("update pseuds set name = '#{ns.penname}' where id = #{new_pseud_id}")
              a = new_a
              a.pseud_id = new_pseud_id
              update_record_target("insert into user_imports (user_id, pseud_id,source_archive_id,source_user_id) values (#{new_a.new_user_id},#{a.pseud_id},#{ns.source_archive_id},#{ns.old_user_id})")
            else
              #user exists, but is being imported
              #insert the mapping value
              puts "---existed"
              ns.penname = a.penname

              #check to see if penname exists as pseud for existing user
              temp_pseud_id = get_pseud_id_for_penname(temp_author_id,ns.penname)
              if temp_pseud_id == 0
                #add pseud if not exist
                begin
                  new_pseud = Pseud.new
                  new_pseud.user_id = temp_author_id
                  new_pseud.name = a.penname
                  new_pseud.is_default = true
                  new_pseud.description = "Imported"
                  new_pseud.save!
                  temp_pseud_id = new_pseud.id

                rescue Exception=>e
                  puts "Error: 111: #{e}"
                end
                begin
                  new_ui = UserImport.new
                  new_ui.user_id = temp_author_id
                  new_ui.pseud_id = temp_pseud_id
                  new_ui.source_user_id = ns.old_user_id
                  new_ui.source_archive_id = ns.source_archive_id
                  new_ui.save!
                rescue Exception=>e
                  puts "Error: 777: #{e}"
                end

                # 'temp_pseud_id = get_pseud_id_for_penname(ns.new_user_id,ns.penname)

                update_record_target("update user_imports set pseud_id = #{temp_pseud_id} where user_id = #{ns.new_user_id} and source_archive_id = #{@import_archive_id}")
                puts "====A"
                ns.new_user_id = temp_pseud_id
                a.pseud_id = temp_pseud_id
              end
            end

          else
            ns.penname = a.penname
            a.pseud_id = get_pseud_id_for_penname(ns.new_user_id,ns.penname)
            puts "#{a.pseud_id} this is the matching pseud id"
          end

          #insert work object
          begin
            new_work = Work.new
            new_work.title = ns.title
            new_work.summary = ns.summary
            new_work.authors_to_sort_on = ns.penname
            new_work.title_to_sort_on = ns.title
            new_work.restricted = true
            new_work.posted = true
            puts "looking for pseud #{a.pseud_id}"
            new_work.pseuds << Pseud.find_by_id(a.pseud_id)
            new_work.revised_at = ns.updated
            new_work.created_at = ns.published
            new_work.fandom_string = @import_fandom
            new_work.rating_string = "Not Rated"
            new_work.warning_strings = "None"
            new_work.errors.full_messages
            puts "old work id = #{ns.old_work_id}"
            new_work.imported_from_url = "#{@import_archive_id}~~#{ns.old_work_id}"
            new_work = add_chapters(new_work,ns.old_work_id)
            new_work.chapters.each do |chap|
              #puts "#{chap.title}"
            end

            collection_array = get_work_collections(ns.categories)
            collection_array.each do |cobj|
              new_work.collections << cobj unless work.collections.include?(cobj)
              puts "Added existing work #{work.title} to #{c.title}"
            end

            new_work.save!
            new_work.chapters.each do |cc|
              puts "attempting to save chapter for #{new_work.id}"
              puts cc.content
              puts cc.title
              puts cc.posted
              puts cc.work_id
              puts cc.position
              cc.work_id = new_work.id
              #cc.save!
              cc.errors.full_messages
            end
            add_chapters2(ns,new_work.id)
            my_tag_list.each do |t|
              add_work_taggings(new_work.id,t)
            end
            
            puts "new work created #{new_work.id}"

          rescue Exception=>e
            puts "Error: 222: #{e}"

          end


          begin
            new_wi = WorkImport.new
            new_wi.work_id = new_work.id
            new_wi.pseud_id = ns.new_user_id
            new_wi.source_archive_id = @import_archive_id
            new_wi.source_work_id = ns.old_work_id
            new_wi.source_user_id = ns.old_user_id
            new_wi.save!

          rescue Exception=>e
            puts "Error: 888: #{e}"
          end
          @connection.close()

        rescue Exception => ex
          puts " Error : " + ex.message
          @connection.close()
        ensure
        end
        i = i + 1
      end
      @connection.close()
    end


    def add_chapters2(ns,new_id)
      case
        when 4
          puts "1121 == Select * from #{@source_chapters_table} where csid = #{ns.old_work_id} order by id asc"

          r = @connection.query("Select * from #{@source_chapters_table} where csid = #{ns.old_work_id}")
          puts "333"
          ix = 1
          r.each do |rr|
            c = ImportChapter.new()
            c.new_work_id = new_id

            c.title = rr[1]
            c.date_posted = rr[4]
            c.body = rr[3]
            c.position = ix
            self.post_chapters(c, @source_archive_type)
          end
        when 3

      end




    end

#copied and modified from mass import rake, stephanies 1/22/2012
#Create archivist and collection if they don't already exist"
    def create_archivist_and_collection

      # make the archivist user if it doesn't exist already
      u = User.find_or_initialize_by_login(@archivist_login)
      if u.new_record?

              u.password = @archivist_password
              u.email = @archivist_email
              u.age_over_13 = "1"
              u.terms_of_service = "1"
              u.password_confirmation = @archivist_password
      end
      #if user isnt an archivist make it so
      unless u.is_archivist?
        u.roles << Role.find_by_name("archivist")
        u.save

      end
      @archivist_user_id = u.id

      # make the collection if it doesn't exist already
      c = Collection.find_or_initialize_by_name(@new_collection_name)
      if c.new_record?
        c.description = @new_collection_description
        c.title = @new_collection_title
      end
      # add the user as an owner if not already one
      unless c.owners.include?(u.default_pseud)
        p = c.collection_participants.where(:pseud_id => u.default_pseud.id).first || c.collection_participants.build(:pseud => u.default_pseud)
        p.participant_role = "Owner"
        c.save
        p.save
      end
      c.save

      @new_collection_id = c.id
      puts "Archivist #{u.login} set up and owns collection #{c.name}."
      if @categories_as_subcollections == true
       puts "Creating sub collections"
        convert_categories_to_collections(0)

      end
    end

    #Post Chapters Fix
    def post_chapters2(c, sourceType)
      case sourceType
        when 4 #storyline
          new_c = Chapter.new
          new_c.work_id =  c.new_work_id
          new_c.created_at = c.date_posted
          new_c.updated_at = c.date_posted
          new_c.posted = 1
          new_c.position = c.position
          new_c.title = c.title
          new_c.summary = c.summary
          new_c.content = c.body
          new_c.save!
          puts "New chapter id #{new_c.id}"
          add_new_creatorship(new_c.id,"chapter",c.pseud_id)
        when 3 #efiction
               #TODO Add efiction3 add chapters
      end
    end

    #add chapters    takes chapters and adds them to import work object
    def add_chapters(ns,old_work_id)
      case @source_archive_type
        when 4 #Storyline
          puts "1121 == Select * from #{@source_chapters_table} where csid = #{old_work_id}"
          r = @connection.query("Select * from #{@source_chapters_table} where csid = #{old_work_id}")
          puts "333"
          ix = 1
          r.each do |rr|
            c = Chapter.new()
            #c.new_work_id = ns.new_work_id     will be made automatically
            #c.pseud_id = ns.pseuds[0]
            c.title = rr[1]
            c.created_at  = rr[4]
            #c.updated_at = rr[4]
            c.content = rr[3]
            c.position = ix
            c.summary = ""
            c.posted = 1
            ns.chapters << c
            ix = ix + 1
            #self.post_chapters(c, @source_archive_type)
          end
        when 3 #efiction 3
               #TODO Add efiction3 add chapters
      end


      return ns

    end


    #adds new creatorship
    def add_new_creatorship(creation_id,creation_type,pseud_id)
      new_creation = Creatorship.new()
      new_creation.creation_type = creation_type
      new_creation.pseud_id = pseud_id
      new_creation.creation_id = chapter_id
      new_creation.save!
      puts "New creatorship #{new_creation.id}"
    end



#Add User
    def add_user(a)
      begin
        login_temp = a.email.tr("@", "")
        login_temp = login_temp.tr(".","")
        #new user model
        new_user = User.new()
        new_user.terms_of_service = true
        new_user.email = a.email
        new_user.login = login_temp
        new_user.password = a.password
        new_user.password_confirmation = a.password
        new_user.age_over_13 = true
        new_user.save!

        #Create Default Pseud / Profile
        new_user.create_default_associateds
        a.new_user_id = new_user.id

        return a
      rescue Exception=>e
        puts "error 1010: #{e}"
      end

    end


    # Set Archive Strings and values basedo on archive type, based on the predinined values used
    # with the particular source archive software
    def set_import_strings
      case @source_archive_type
      when 1 # efiction 1
          @source_chapters_table = "#{@temp_table_prefix}#{@source_table_prefix}chapters"
          @source_reviews_table = "#{@temp_table_prefix}#{@source_table_prefix}reviews"
          @source_stories_table = "#{@temp_table_prefix}#{@source_table_prefix}stories"
          @source_categories_table = "#{@temp_table_prefix}#{@source_table_prefix}categories"
          @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix}authors"
          @source_characters_table = "#{@temp_table_prefix}#{@source_table_prefix}characters"
          @source_warnings_table = "#{@temp_table_prefix}#{@source_table_prefix}warnings"
          @source_generes_table = "#{@temp_table_prefix}#{@source_table_prefix}generes"
          @get_author_from_source_query = " "
        when 2 #efiction2
          @source_chapters_table = "#{@temp_table_prefix}#{@source_table_prefix}chapters"
          @source_reviews_table = "#{@temp_table_prefix}#{@source_table_prefix}reviews"
          @source_stories_table = "#{@temp_table_prefix}#{@source_table_prefix}stories"
          @source_characters_table = "#{@temp_table_prefix}#{@source_table_prefix}characters"
          @source_warnings_table = "#{@temp_table_prefix}#{@source_table_prefix}warnings"
          @source_generes_table = "#{@temp_table_prefix}#{@source_table_prefix}generes"
          @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix}authors"
          @get_author_from_source_query = "Select realname, penname, email, bio, date, pass, website, aol, msn, yahoo, icq, ageconsent from  #{@source_users_table} where uid ="
        when 3 #efiction3
          @source_chapters_table = "#{@temp_table_prefix}#{@source_table_prefix}chapters"
          @source_reviews_table = "#{@temp_table_prefix}#{@source_table_prefix}reviews"
          @source_challenges_table = "#{@temp_table_prefix}#{@source_table_prefix}challenges"
          @source_stories_table = "#{@temp_table_prefix}#{@source_table_prefix}stories"
          @source_categories_table = "#{@temp_table_prefix}#{@source_table_prefix}categories"
          @source_characters_table = "#{@temp_table_prefix}#{@source_table_prefix}characters"

          @source_ratings_table = "#{@temp_table_prefix}#{@source_table_prefix}ratings"
          @source_classes_table = "#{@temp_table_prefix}#{@source_table_prefix}classes"
          @source_class_types_table = "#{@temp_table_prefix}#{@source_table_prefix}class_types"
          @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix} authors"
          @get_author_from_source_query = "Select realname, penname, email, bio, date, pass from #{@source_users_table} where uid ="
        
        when 4 #storyline
          @source_chapters_table = "#{@temp_table_prefix}#{@source_table_prefix}chapters"
          @source_reviews_table = "#{@temp_table_prefix}#{@source_table_prefix}reviews"
          @source_stories_table = "#{@temp_table_prefix}#{@source_table_prefix}stories"
          @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix}users"
          @source_categories_table = "#{@temp_table_prefix}#{@source_table_prefix}category"
          @source_subcategories_table = "#{@temp_table_prefix}#{@source_table_prefix}subcategory"
          @source_hitcount_table = "#{@temp_table_prefix}#{@source_table_prefix}rating"
          @source_ratings_table = nil #None
          @get_author_from_source_query = "SELECT urealname, upenname, uemail, ubio, ustart, upass, uurl, uaol, umsn, uicq from #{@source_users_table} where uid ="
          
        when 5 #otwarchive
          @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix}users"
      end
    end

    ##get import user object, by source_user_id,
    ##return import user object
    def get_import_user_object_from_source(source_user_id)
      a = ImportUser.new()

      r = @connection.query("#{@get_author_from_source_query} #{source_user_id}")
      @connection

      r.each  do |r|
        a.old_user_id = source_user_id
        a.realname = r[0]
        a.source_archive_id = @import_archive_id
        a.penname = r[1]
        a.email = r[2]
        a.bio = r[3]
        a.joindate = r[4]
        a.password = r[5]
        if @source_archive_type == 2 || @source_archive_type == 4
          a.website = r[6]
          a.aol = r[7]
          a.msn = r[8]
          a.icq = r[9]
          a.bio = self.build_bio(a).bio
          a.yahoo = ""
          if @source_archive_type == 2
            a.yahoo = r[10]
            a.isadult = r[11]
          end
        end
      end
      return a
    end

# Consolidate Author Fields into User About Me String
    def build_bio(a)
      if a.yahoo == nil
        a.yahoo = " "
      end
      if a.aol.length > 1 || a.yahoo.length > 1 || a.website.length > 1 || a.icq.length > 1 || a.msn.length > 1
        if a.bio.length > 0
          a.bio << "<br /><br />"
        end
      end
      if a.aol.length > 1
        a.bio << " <br /><b>AOL / AIM :</b><br /> #{a.aol}"
      end
      if a.website.length > 1
        a.bio << "<br /><b>Website:</ b><br /> #{a.website}"
      end
      if a.yahoo.length > 1
        a.bio << "<br /><b>Yahoo :</b><br /> #{a.yahoo}"
      end
      if a.msn.length > 1
        a.bio << "<br /><b>Windows Live:</ b><br /> #{a.msn}"
      end
      if a.icq.length > 1
        a.bio << "<br /><b>ICQ :</b><br /> #{a.icq}"
      end
      return a
    end
#TODO

  def get_work_collections(collectionstring)

    tempstring = collectionstring
    temparray = Array.new



    collectionstring = tempstring.split(",")
    collectionstring.each do |c|
    newcollectionid = get_single_value_target("Select new_id from collection_imports where source_archive_id = #{@import_archive_id} AND old_id = #{c} ")
    tempcollection = Collection.find(newcollectionid)
    temparray.push(tempcollection)
    end
    collectionstring = temparray
    return temparray

  end

  #used with efiction 3 archives
  def get_work_class_tags(tl,classstr,mytype)
  classsplit = nil
  classplit = classstr.split(",")
  classsplit.each do |x|
    a = "Select class_id, class_type, class_name from #{@source_classes_table} where class_id = #{x}"
    r = @connection.query(a)
    r.each do |r|
      nt = ImportTag.new()
      if mytype == "characters"
        case mytype
        when "characters"
          nt.tag_type = "character"
        when "classes"
          nt.tag_type = "freeform"  
        end
      end
      nt.old_id = r1[0]
      nt.tag = r1[2]
      tl.push(nt)
    end
   end
   return tl
  end


    #return old new id from user_imports table based on old user id & source archive
    def get_new_user_id_from_imported(old_id,source_archive)
      puts "#{old_id}"
      return get_single_value_target("select user_id from user_imports where source_user_id = #{old_id} and source_archive_id = #{source_archive}")
    end
    #get default pseud given userid
    def get_default_pseud_id(user_id)
      return get_single_value_target("select id from pseuds where user_id = #{user_id}")
    end

    #given valid user_id search for psued belonging to that user_id with matching penname
    def get_pseud_id_for_penname(user_id,penname)
      puts "11-#{user_id}-#{penname}"
      return get_single_value_target("select id from pseuds where user_id = #{user_id} and name = '#{penname}'")
    end
    
    def get_new_work_id_fresh(source_work_id,source_archive_id)
      puts "13-#{source_work_id}~~#{source_archive_id}"
      return get_single_value_target("select id from works where imported_from_url = '#{source_work_id}~~#{source_archive_id}'")
    end

    # Return new story id given old id and archive
    def get_new_work_id_from_old_id(source_archive_id, old_work_id) #
      puts "12-#{source_archive_id}-#{old_work_id}"
      return get_single_value_target(" select work_id from work_imports where source_archive_id #{source_archive_id} and old_work_id=#{old_work_id}")
    end

    # Get New Author ID from old User ID & old archive ID
    def get_new_author_id_from_old(old_archive_id, old_user_id)
      return get_single_value_target(" Select user_id from user_imports where source_archive_id = #{old_archive_id} and source_user_id = #{old_user_id} ")
    end

    #check for existing user by email address
    def get_user_id_from_email(emailaddress)
      return get_single_value_target("select id from users where email = '#{emailaddress}'")
    end
    
    #query and return a single value from database
    def get_single_value_target(query)
      begin
        r = @connection.query(query)
        puts "single val query = #{query}"
        if r.num_rows == 0
          return 0
        else
          r.each do |rr|
            return rr[0]
          end
        end
      rescue Exception => ex
        @connection.close()
        puts ex.message
      end

    end

    # Update db record takes query as peram (any non returning query)
    def update_record_target(query)

      begin
        rowsEffected = 0
        rowsEffected = @connection.query(query)


        return rowsEffected
      rescue Exception => ex
        @connection.close()
        puts ex.message
      ensure
      end
    end


#take the settings from the form and pass them into the internal instance specific variables
#for the mass import object.
def populate(settings)
    
  #database values
    @database_host = settings[:database_host]
    @database_name = settings[:database_name]
    @database_password = settings[:database_password]
    @database_username = settings[:database_username]
    @source_table_prefix = settings[:source_table_prefix]
    #define temp value for temp appended prefix for table names
    @temp_table_prefix = "ODimport"
    if !settings[:temp_table_prefix] == nil
      @temp_table_prefix = settings[:temp_table_prefix]  
    end
  #archivist values
    @archivist_email = settings[:archivist_email]
    @archivist_login = settings[:archivist_username]
    @archivist_password = settings[:archivist_password]
  #import values
    @import_fandom = settings[:import_fandom]
    @import_name = settings[:import_name]
    @import_id = settings[:import_id]
    @import_reviews = settings[:import_reviews]
    @categories_as_subcollections = settings[:categories_as_subcollections]
  #collection values
    @create_collection = settings[:create_collection]
    @new_collection_description = settings[:new_collection_description]
    @new_collection_id = settings[:new_collection_id]
    @new_collection_name = settings[:new_collection_short_name]
    @new_collection_owner = settings[:new_collection_owner]
    @new_collection_title = settings[:new_collection_title]
    @new_collection_restricted = settings[:new_collection_restricted]
  #notification values
    @new_notification_message = settings[:new_message]
    @existing_notification_message = settings[:existing_message]
    
   case settings[:archive_type]
   when "efiction3"
     set_import_stringts(3)
   when "storyline18"
     set_import_strings(4)
   when "efiction1"
     set_import_strings(1)
   when "efiction2"
     set_import_string(2)
   when "otwarchive"
     set_import_strings(5) 
   end


  #Overrides for abnormal / non-typical imports (advanced use only)
    if settings[:override_tables] == 1 
       @source_users_table = settings[:source_users_table]
       @source_chapters_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_chapters_table]}"
       @source_reviews_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_reviews_table]}"
       @source_stories_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_stories_table]}"
       @source_users_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_users_table]}"
       @source_categories_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_category_table]}"
       @source_subcategories_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_subcategory_table]}"
       @source_ratings_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_ratings_table]}"
       @source_classes_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_classes_table]}"
       @source_class_types_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_class_types_table]}"
       @source_warnings_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_warnings_table]}"
       @source_characters_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_characters_table]}"
       @source_challenges_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_challenges_table]}"
       @source_collections_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_collections_table]}"
       @source_hitcount_table =  "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_hitcount_table]}"
       @source_user_preferences_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_user_preferences_table]}"
       @source_user_profile_fields_table ="#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_user_profiles_fields_table]}"
       @source_user_profile_values_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_user_profiles_values_table]}"
       @source_user_profiles_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_user_profiles_table]}"
       @source_pseuds_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_pseuds_table]}"
       @source_collection_items_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_collection_items_table]}"
       @source_collection_participants_table = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_collection_participants]}"
       #other possible source tables to be added here

    end
    if settings[:override_target_ratings] == 1
       @target_rating_1 = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_target_rating_1]}" #NR
       @target_rating_2 = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_target_rating_2]}" #general audiences
       @target_rating_3 = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_target_rating_3]}" #teen
       @target_rating_4 = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_target_rating_4]}" #Mature   
       @target_rating_5 = "#{@temp_table_prefix}#{@source_table_prefix}#{settings[:source_target_rating_5]}" #Explicit
    end 
  #initialize database connection object
  @connection = Mysql.new(@database_host,@database_username,@database_password,@database_name)
  end



end
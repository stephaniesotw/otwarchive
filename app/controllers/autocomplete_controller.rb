class AutocompleteController < ApplicationController
  respond_to :json
  
  skip_before_filter :store_location
  skip_before_filter :set_current_user, :except => [:collection_parent_name, :owned_tag_sets, :site_skins]
  skip_before_filter :fetch_admin_settings
  skip_before_filter :set_redirects
  skip_before_filter :sanitize_params # can we dare!

  #### DO WE NEED THIS AT ALL? IF IT FIRES WITHOUT A TERM AND 500s BECAUSE USER DID SOMETHING WACKY SO WHAT
  # # If you have an autocomplete that should fire without a term add it here
  # before_filter :require_term, :except => [:tag_in_fandom, :relationship_in_fandom, :character_in_fandom, :nominated_parents]
  # 
  # def require_term
  #   if params[:term].blank?
  #     flash[:error] = ts("What were you trying to autocomplete?")
  #     redirect_to(request.env["HTTP_REFERER"] || root_path) and return
  #   end
  # end
  # 
  #########################################
  ############# LOOKUP ACTIONS GO HERE
  
  # PSEUDS
  def pseud
    render_output(Pseud.autocomplete_lookup(:search_param => params[:term], :autocomplete_prefix => "autocomplete_pseud").map {|res| Pseud.fullname_from_autocomplete(res)})
  end
  
  ## TAGS  
  private
    def tag_output(search_param, tag_type)
      render_output Tag.autocomplete_lookup(:search_param => search_param, :autocomplete_prefix => "autocomplete_tag_#{tag_type}").map {|r| Tag.name_from_autocomplete(r)}
    end
  public  
  # these are all basically duplicates but make our calls to autocomplete more readable
  def tag; tag_output(params[:term], params[:type]); end
  def fandom; tag_output(params[:term], "fandom"); end
  def character; tag_output(params[:term], "character"); end
  def relationship; tag_output(params[:term], "relationship"); end
  def freeform; tag_output(params[:term], "freeform"); end

  
  ## TAGS IN FANDOMS
  private
    def tag_in_fandom_output(params)
      render_output(Tag.autocomplete_fandom_lookup(params).map {|r| Tag.name_from_autocomplete(r)})
    end
  public
  def tag_in_fandom; tag_in_fandom_output(params); end
  def character_in_fandom; tag_in_fandom_output(params.merge({:tag_type => "character"})); end
  def relationship_in_fandom; tag_in_fandom_output(params.merge({:tag_type => "relationship"})); end


  ## TAGS IN SETS
  #
  # Note that only tagsets in OwnedTagSets are in autocomplete
  #

  # expects the following params: 
  # :tag_set - tag set ids comma-separated
  # :tag_type - tag type as a string unless "all" desired
  # :in_any - set to false if only want tags in ALL specified sets
  # :term - the search term
  def tags_in_sets
    results = TagSet.autocomplete_lookup(params)
    render_output(results.map {|r| Tag.name_from_autocomplete(r)})
  end
  
  # expects the following params: 
  # :fandom - fandom name(s) as an array or a comma-separated string
  # :tag_set - tag set id(s) as an array or a comma-separated string
  # :tag_type - tag type as a string unless "all" desired
  # :include_wrangled - set to false if you only want tags from the set associations and NOT tags wrangled into the fandom
  # :fallback - set to false to NOT do 
  # :term - the search term
  def associated_tags
    if params[:fandom].blank? 
      render_output([ts("Please select a fandom first!")])
    else
      results = TagSetAssociation.autocomplete_lookup(params)
      render_output(results.map {|r| Tag.name_from_autocomplete(r)})
    end
  end
  
  ## NONCANONICAL TAGS
  def noncanonical_tag
    search_param = params[:term]
    tag_class = params[:type].classify.constantize
    render_output(tag_class.by_popularity
                      .where(["canonical = 0 AND name LIKE ?",
                              '%' + search_param + '%']).limit(10).map(&:name))
  end
  
  
  # more-specific autocompletes should be added below here when they can't be avoided


  # Nominated parents
  def nominated_parents
    render_output(TagNomination.for_tag_set(OwnedTagSet.find(params[:tag_set_id])).nominated_parents(params[:tagname], params[:term]))
  end


  # look up collections ranked by number of items they contain

  def collection_fullname
    results = Collection.autocomplete_lookup(:search_param => params[:term], :autocomplete_prefix => "autocomplete_collection_all").map {|res| Collection.fullname_from_autocomplete(res)}
    render_output(results)
  end

  # return collection names
  
  def open_collection_names
    # in this case we want different ids from names so we can display the title but only put in the name
    results = Collection.autocomplete_lookup(:search_param => params[:term], :autocomplete_prefix => "autocomplete_collection_open").map do |str| 
      {:id => Collection.name_from_autocomplete(str), :name => Collection.title_from_autocomplete(str)}
    end
    respond_with(results)
  end
  
  # For creating collections, autocomplete the name of a parent collection owned by the user only
  def collection_parent_name
    render_output(current_user.maintained_collections.top_level.with_name_like(params[:term]).value_of(:name).sort)
  end

  # for looking up existing urls for external works to avoid duplication 
  def external_work
    render_output(ExternalWork.where(["url LIKE ?", '%' + params[:term] + '%']).limit(10).order(:url).value_of(:url))    
  end
  
  # encodings for importing
  def encoding
    encodings = Encoding.name_list.select {|e| e.match(/#{params[:term]}/i)}
    render_output(encodings)
  end

  # people signed up for a challenge
  def challenge_participants
    search_param = params[:term]
    collection_id = params[:collection_id]
    render_output(Pseud.limit(10).order(:name).joins(:challenge_signups)
                    .where(["pseuds.name LIKE ? AND challenge_signups.collection_id = ?", 
                            '%' + search_param + '%', collection_id]).map(&:byline))
  end
  
  # owned tag sets that are usable by all
  def owned_tag_sets
    if params[:term].length > 0
      search_param = '%' + params[:term] + '%'
      render_output(OwnedTagSet.limit(10).order(:title).usable.where("owned_tag_sets.title LIKE ?", search_param).collect(&:title))
    end
  end
  
  # skins for parenting
  def site_skins
    if params[:term].present?
      search_param = '%' + params[:term] + '%'
      query = Skin.site_skins.where("title LIKE ?", search_param).limit(15).sort_by_recent
      if logged_in?
        query = query.approved_or_owned_by(current_user)
      else
        query = query.approved_skins
      end
      render_output(query.value_of(:title))
    end
  end
  
private

  def render_output(result_strings)
    if result_strings.first.is_a?(String)
      respond_with(result_strings.map {|str| {:id => str, :name => str}})
    else
      respond_with(result_strings)
    end
  end
  

end


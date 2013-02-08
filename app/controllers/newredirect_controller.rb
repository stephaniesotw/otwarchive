class NewredirectController < ApplicationController

  
  # GET /admins
  # GET /admins.xml
  def index
     destination = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"

     temp_work = Work.where(["imported_from_url = ?", destination]).first
     send_to = "http://archiveofourown.org/works/#{temp_work.id}"
    redirect_to send_to, :status => 301
  end

  # GET /admins/1
  # GET /admins/1.xml
  def show
    @admin = Admin.find(params[:id])
  end


end

class Admin::ImportsController < ApplicationController

  before_filter :admin_only

  def index
    @nmi = MassImportTool.new()
  end

  # PUT /admin_settings/1
  # PUT /admin_settings/1.xml
  def update
    unless params[:import_setting] = nil
    @import_settings = params[:import_setting]
    end
    
    @nmi = MassImportTool.new()
    @nmi.populate(@import_settings)
    #setflash; flash[:notice] = ts("Running Import Task  #{@import_settings[:import_short_name]}")
    @nmi.perform
      
  end

end

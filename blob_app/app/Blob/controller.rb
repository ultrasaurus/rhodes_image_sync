require 'rho'
require 'rho/rhocontroller'
require 'helpers/application_helper'
require 'rho/rhoerror'

class BlobController < Rho::RhoController
  
  include ApplicationHelper
    
  def index
    @images = Blob.find(:all)
  end
  
	def downloading_data
  end

  def take
    Camera::take_picture(url_for :action => :camera_callback)
    redirect :action => :index
  end
  
  def choose
    Camera::choose_picture(url_for :action => :camera_callback)
    redirect :action => :index
  end
  
  def delete
     @image = Blob.find(@params['id'])
     @image.destroy
     redirect :action => :index
   end

  def camera_callback
   if @params['status'] == 'ok'
     #create image record in the DB
     image = Blob.new({'image_uri'=>@params['image_uri']})
     image.save
     puts "new Image object: " + image.inspect
     WebView.navigate "/app/Blob"
   end  
  end
  
  def sync
    SyncEngine::dosync
    redirect :action => :index
  end

 	def authenticate
 	  if SyncEngine::logged_in > 0
      redirect :action => :index
    else	  
      begin
        SyncEngine::login("admin", "password", url_for(:action => :login_callback) )
        render :action => :authenticating
      rescue RhoError => e
        puts e.message
      end
    end
  end
  
    # handles errors and redirects to home on no error
  def sync_notify
    status = @params['status'] ? @params['status'] : ""
    if status == "error"
      errCode = @params['error_code'].to_i
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      else 
        @msg = Rho::RhoError.new(errCode).message
      end
     
      WebView.navigate(url_for(:action => :server_error, :query => {:msg => @msg}))
    elsif status == "ok"
    	
      if SyncEngine::logged_in > 0
        WebView.navigate "/app/Blob"
      else
        # rhosync has logged us out
      end
    end  
  end
  
  def login_callback
    errCode = @params['error_code'].to_i
    if errCode == 0
    	# run sync if we were successful
      Blob.set_notification("/app/Blob/sync_notify", "doesnotmatter")
      WebView.navigate(url_for(:action => :downloading_data))
      SyncEngine::dosync
    else
      if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
        @msg = @params['error_message']
      elsif errCode == Rho::RhoError::ERR_NETWORK
        @msg = "Could not establish network connection"
      elsif errCode == Rho::RhoError::ERR_REMOTESERVER
        @msg = "Could not connect to sync server."
      end
        
      if !@msg || @msg.length == 0   
        @msg = Rho::RhoError.new(errCode).message
      end
      
   		puts @msg
    end  
  end
  
  def server_error
    @msg = @params['msg']
  end
  
end
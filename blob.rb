class Blob < SourceAdapter
	def query(conditions=nil,limit=nil,offset=nil)
		@result={}

    new_item = {
    	'image_uri' => "http://github.com/images/modules/header/logov3.png", 
    	'attrib_type' => 'blob.url'
  	}
    @result["123456789"] = new_item
    
    @result

#		ov=ObjectValue.new
#		o.source_id=@source.id
#    o.object="123456"
#    o.attrib="url"
#    o.user_id = @source.current_user.id
#		ov.blob="http://github.com/images/modules/header/logov3.png"
	end
end
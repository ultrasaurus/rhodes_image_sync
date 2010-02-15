class Blob < SourceAdapter
  PATH = File.join(RAILS_ROOT,'public','images')
  BASEURL = 'http://localhost:3000'
  
  def initialize(source,credential)
    super(source,credential)
  end
 
  def login
  end
 
  def query
    @result={}
    Dir.entries(PATH).each do |entry|
      new_item = {'image_uri' => BASEURL+'/images/'+entry, 'attrib_type' => 'blob.url'}
      unless entry == '..' || entry == '.' || entry == '.keep'
        p "Found: #{entry}"
        @result[entry.hash.to_s] = new_item
      end
    end
    @result
  end
 
  def sync
    super
  end
 
  def create(name_value_list,blob=nil)
    if blob
      obj = ObjectValue.find(:first, :conditions => "object = '#{blob.instance.object}' AND value = '#{name_value_list[0]["value"]}'")
      path = blob.path.gsub(/\/\//,"\/#{obj.id}\/")
      name = name_value_list[0]["value"]
      `cp #{path} #{File.join(PATH,name)}`
    end
  end
 
  def update(name_value_list)
  end
 
  def delete(name_value_list)
    Dir.entries(PATH).each do |entry|
      obj_id = name_value_list[0]['value']
      if entry.hash.to_s == obj_id
        p "Removing: #{entry}"
        `rm #{File.join(PATH,entry)}`
      end
    end
  end
 
  def logoff
  end
end
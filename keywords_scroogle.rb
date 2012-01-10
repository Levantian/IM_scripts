require 'rubygems'
require 'mechanize'

url = 'http://www.scroogle.org/cgi-bin/scraper.htm'  


#Save rankings of website to this file
now = Time.now # Get time, to attach date to ranks.txt
datenow =  now.strftime("%Y-%m-%d")

directory_name = Dir::pwd+"/results_scroogle"
# Create directory if it doesn't exist
if !File.directory?(directory_name)
	Dir::mkdir(directory_name)
end

foutname = "results_scroogle/ranks_"+datenow+".txt"
f = File.open(foutname, 'w')


# Output header
f.write("*****Scroogle Results: "+datenow+" ********\n")
f.write("URL ------ Phase Match ----- Exact Match")

a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
        }

max_count = 5 #This is a limit by scroogle
furls = File.open("websites.txt").each { |line|

  temp = line
  ind = temp.index(";")
  url1 = temp[0,ind]
  temp = temp[ind+1,temp.length]
  keyword = temp

  #Get Exact Match
  page = a.get(url)
  #pp page
  search_form = page.form_with(:name => 'qform')
  search_form.Gw = "\"#{keyword}\""
  search_form.radiobuttons.last.click
  page = search_form.click_button

  text = page.body
  match = text[/(.*)#{url1}(.*)/]
  
  if match == nil
    count = 1;
    
    while count < max_count && match == nil do
      print count
      print " "
      temp_form = page.forms[1]
      temp_form.checkbox.check
     page = temp_form.click_button
      
      text = page.body
      match = text[/(.*)#{url1}(.*)/]
      count = count+1
    end
   end 
  
  
  if match == nil
    e_match = -1
  else
    ind = match.index(".")
    e_match = match[0,ind]
  end

  #Get Phase Match
  page = a.get(url)
  search_form = page.form_with(:name => 'qform')
  search_form.Gw = keyword
  search_form.radiobuttons.last.click
  page = search_form.click_button

  text = page.body
  match = text[/(.*)#{url1}(.*)/]
  if match == nil
    count = 1;
    
    while count < max_count && match == nil do
      print count
      print " "
      temp_form = page.forms[1]
      temp_form.checkbox.check
     page = temp_form.click_button
      
      text = page.body
      match = text[/(.*)#{url1}(.*)/]
      count = count+1
    end
   end 
    
    
  if match == nil
     p_match = -1
    
  else
    ind = match.index(".")
    p_match = match[0,ind]
  end

  f.write("\n#{url1} ------ #{e_match} ------ #{p_match}")
}




f.close

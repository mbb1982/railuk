
require 'scraperwiki'
require 'nokogiri'
require 'mechanize'
$agent = Mechanize.new


def page_to_table(url,table,keys,on_head,on_row)
  page = $agent.get(url)
  while page
    first_row = true
    fields = {}
    page.search("table tr").each { |row|
      puts row.inner_text
      if first_row
        fields = row.search("td").map{|field| puts field
        field.inner_text.sub(/^(\W)+/,"").gsub(/\W/,"_")}
        puts fields
        if !on_head.nil?
          on_head.call(fields)
        end
        first_row = false
      else
        add_to_db = true
        item = {}
        values = row.search("td").map{|field| field.inner_text.sub(/^(\W)+/,"")}
        next if values[0] == "" || values[0] == nil
        i=0
        values.each{|value|
          key = fields[i]
          item[key]=value
          i=i.next
        }
        puts item
        
        if !on_row.nil?
          on_row.call(item,add_to_db)
        end
        
        if add_to_db
          ScraperWiki::save_sqlite(keys,item,table)
        end
      end
    }
    if next_link = page.links_with(:text=>"Next")[0]
      page = next_link.click
    else
      page = nil
    end
    
  end
end

page_to_table('http://www.railuk.info/diesel/unit_search.php',"stock",['Number'],
lambda {|x| x.map!{|v| v.sub(/Set_Number/,"Number")}},
lambda {|x| x.delete!("Car_Numbers")})

page_to_table('http://www.railuk.info/diesel/class_search.php','class',['Class'],nil,nil)
page_to_table('http://www.railuk.info/diesel/depot_search.php','depot',['Depot'],nil,nil)
page_to_table('http://www.railuk.info/diesel/livery_search.php','livery',['Livery_Code'],nil,nil)
page_to_table('http://www.railuk.info/diesel/pool_search.php','pool',['Pool_Code'],nil,nil)
page_to_table('http://www.railuk.info/diesel/loco_search.php','stock',['Number'],nil,nil)



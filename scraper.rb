
require 'scraperwiki'
require 'nokogiri'
require 'mechanize'
$agent = Mechanize.new


def page_to_table(url,table,keys,on_head,on_row)
  page = $agent.get(url)
  first_row = true
  page.search("table tr").each { |row|
    if first_row
      fields = row.search("td").map{|field| field.inner_text.sub!(/^(\W)+/,"")}
      if !on_head.nil?
        on_head.call(fields)
      end
      first_row = false
    else
      add_to_db = true
      values = row.search("td").map{|field| field.inner_text.sub!(/^(\W)+/,"")}
      next if values[0] == "" || values[0] == nil
      i=0
      values.each{|value|
        key = fields[i]
        item[key]=value
        i=i.next
      }
      
      if !on_row.nil?
        on_row.call(item,add_to_db)
      end
      
      if add_to_db
        ScraperWiki::save_sqlite(keys,item,table)
      end
    end
  }
end

page_to_table('http://www.railuk.info/diesel/loco_search.php','stock',['number'],nil,nil)



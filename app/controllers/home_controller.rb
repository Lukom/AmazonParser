class HomeController < ApplicationController
  def index
    book_links = %w{
        http://www.amazon.com/Crafting-Rails-Applications-Development-Programmers/dp/1934356735/ref=pd_sim_b_9
        http://www.amazon.com/Ruby-Rails-Tutorial-Addison-Wesley-Professional/dp/0321743121/ref=pd_bxgy_b_text_b
        http://www.amazon.com/Rails-AntiPatterns-Refactoring-Addison-Wesley-Professional/dp/0321604814/ref=pd_sim_b_8
        http://www.amazon.com/The-Rails-View-Maintainable-Experience/dp/1934356875/ref=pd_sim_b_5
        http://www.amazon.com/Rails-Recipes-3-Edition/dp/1934356778/ref=pd_sim_b_22
        http://www.amazon.com/The-Ruby-Way-Techniques-Programming/dp/0321714636/ref=sr_1_2?s=books&ie=UTF8&qid=1333275367&sr=1-2
        http://www.amazon.com/NoSQL-Ruby-Way-Durran-Jordan/dp/0321768043/ref=sr_1_9?s=books&ie=UTF8&qid=1333275367&sr=1-9
        http://www.amazon.com/Practical-Object-Oriented-Addison-Wesley-Professional/dp/0321721330/ref=sr_1_20?s=books&ie=UTF8&qid=1333275423&sr=1-20
        http://www.amazon.com/Deploying-Rails-Automate-Deploy-Maintain/dp/1934356956/ref=sr_1_22?s=books&ie=UTF8&qid=1333275423&sr=1-22
        http://www.amazon.com/Ruby-Rails-Tutorial-Example-Edition/dp/0321832051/ref=sr_1_25?s=books&ie=UTF8&qid=1333275451&sr=1-25
        http://www.amazon.com/Ruby-MongoDB-Development-Beginners-Guide/dp/1849515026/ref=sr_1_34?s=books&ie=UTF8&qid=1333275451&sr=1-34
        http://www.amazon.com/Sass-Compass-Action-Wynn-Netherland/dp/1617290149/ref=sr_1_37?s=books&ie=UTF8&qid=1333275517&sr=1-37
        http://www.amazon.com/Ruby-Best-Practices-Gregory-Brown/dp/0596523009/ref=pd_sim_b_30
        http://www.amazon.com/Eloquent-Ruby-Addison-Wesley-Professional-Series/dp/0321584104/ref=pd_sim_b_4
        http://www.amazon.com/Rails-Way-Addison-Wesley-Professional-Ruby/dp/0321601661
    }

    books_raw_html = Rails.cache.fetch(:boors_raw_html) { book_links.map{|book_link| IO.read(open(book_link))} }

    @books = books_raw_html.map.each_with_index do |raw_html, i|
      doc = Nokogiri::HTML(raw_html)
      book_link = book_links[i]
      puts "===> #{book_link}"

      {
          :url  => book_link,
          :name => doc.search('#btAsinTitle').first.try(:inner_html),
          :img_src => doc.search('#prodImage').first[:src].to_s,
          :price => doc.search('#actualPriceValue > b').first.try(:content),
          :likes => doc.search('.amazonLikeCount').first.try(:content),
          :pages => doc.search('#productDetails ~ table .content > ul > li')[0].try(:content),
          :publisher => doc.search('#productDetails ~ table .content > ul > li')[1].try(:content),
          :reviews => doc.search('.tiny > .crAvgStars > a').first.try(:content),
          :stars => doc.search('.asinReviewsSummary.acr-popover.non-lazy > a > .swSprite').first.try(:[], :title).to_s,
          :pub_date => doc.search('#ps-content .buying span')[1].try(:content),
          :description => doc.search('#outer_postBodyPS > div').first.try(:inner_html),
      }
    end
  end
end

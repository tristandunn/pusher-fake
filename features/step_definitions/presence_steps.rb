Then /^I should see (\d+) clients?$/ do |count|
  within("#presence") do
    should have_css("header h1 span", text: count)
    should have_css("ul li", count: count.to_i)
  end
end

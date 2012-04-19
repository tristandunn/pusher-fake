Then /^I should see (\d+) clients?(?: with name "([^"]+)")?$/ do |count, name|
  within("#presence") do
    should have_css("header h1 span", text: count)
    should have_css("ul li:contains('#{name}')", count: count.to_i)
  end
end

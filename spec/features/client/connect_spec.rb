require "spec_helper"

feature "Client connecting to the server" do
  scenario "successfully connects" do
    visit "/"

    expect(page).to have_content("Client connected.")
  end
end

require "rails_helper"

RSpec.describe "Completing Onboarding", type: :system, js: true do
  let(:password) { Faker::Internet.password(min_length: 8) }

  before do
    allow(SiteConfig).to receive(:allow_email_password_registration).and_return(true)
    allow(SiteConfig).to receive(:allow_email_password_login).and_return(true)
  end

  context "when the user hasn't seen onboarding" do
    xit "does not render the onboarding task card on the feed" do
      sign_in(user)
      visit "/"

      # Explicitly test that the task card element HTML is not on the page.
      expect(page.html).not_to include("onboarding-task-card")
    end
  end

  context "when the user has seen onboarding" do
    let(:user) { create(:user, password: password, password_confirmation: password) }

    before do
      visit sign_up_path
      log_in_user(user)
    end

    it "logs in and renders the feed" do
      expect(page).to have_current_path("/?signin=true")
      expect(page.html).not_to include("onboarding-container")
    end

    xit "renders the feed and onboarding task card" do
      visit "/"

      wait_for_javascript
      expect(page).to have_css(".onboarding-task-card")
    end

    it "can dismiss the onboarding task card" do
      visit "/"

      wait_for_javascript
      expect(page).to have_css(".onboarding-task-card")

      find(".onboarding-task-card .close").click
      expect(page).not_to have_css(".onboarding-task-card")
    end
  end

  # TODO: Vaidehi Joshi - Extract this into a reusable helper
  def log_in_user(user)
    fill_in("user_email", with: user.email)
    fill_in("user_password", with: user.password)
    click_button("Continue", match: :first)
  end
end

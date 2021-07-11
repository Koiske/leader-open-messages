require "rails_helper"

RSpec.describe "leader-open-messages" do
	let(:user_tl1) { Fabricate(:user, trust_level: 1) }
	let(:user_tl2) { Fabricate(:user, trust_level: 2) }
	let(:user_tl4) { Fabricate(:user, trust_level: 4) }

	let(:always_open) { Fabricate(:user, trust_level: 2) }
	
	let(:user_tl1_closed) { Fabricate(:user, trust_level: 1) }
	let(:user_tl1_muted_tl2) { Fabricate(:user, trust_level: 1) }
	let(:user_tl1_muted_tl4) { Fabricate(:user, trust_level: 1) }

	before do
		SiteSetting.enable_personal_messages = true
		SiteSetting.min_trust_to_send_messages = 1

		user_tl1_closed.user_option.update!(allow_private_messages: false)

		updater_tl2 = UserUpdater.new(user_tl1_muted_tl2, user_tl1_muted_tl2)
		updater_tl2.update_muted_users("#{user_tl2.username}")

		updater_tl4 = UserUpdater.new(user_tl1_muted_tl4, user_tl1_muted_tl4)
		updater_tl4.update_muted_users("#{user_tl4.username}")
	end

	def check_can_message(target_user, expected_status: 200)
		post "/posts.json", params: {
          raw: "Hello there #{target_user.username}!",
          archetype: 'private_message',
          title: "This is some post especially for you, #{target_user.username}!",
          target_usernames: "#{target_user.username},#{always_open.username}"
        }
		
		expect(response.status).to eq(expected_status)
	end

	context "disabled" do

		before do
			SiteSetting.leader_open_messages_enabled = false
		end

		context "as regular user" do

			before do
				sign_in(user_tl2)
			end

			it "should allow messages that are not restricted" do
				check_can_message(user_tl1)
				check_can_message(user_tl4)
			end

			it "should block messages to users that they are muted by" do
				check_can_message(user_tl1_muted_tl2, expected_status: 422)
			end

			it "should block messages to users that have messages closed" do
				check_can_message(user_tl1_closed, expected_status: 422)
			end

		end

		context "as leader" do

			before do
				sign_in(user_tl4)
			end

			it "should allow messages that are not restricted" do
				check_can_message(user_tl1)
				check_can_message(user_tl2)
			end

			it "should block messages to users that they are muted by" do
				check_can_message(user_tl1_muted_tl4, expected_status: 422)
			end

			it "should block messages to users that have messages closed" do
				check_can_message(user_tl1_closed, expected_status: 422)
			end

		end
	end

	context "enabled" do

		before do
			SiteSetting.leader_open_messages_enabled = true
		end

		context "as regular user" do

			before do
				sign_in(user_tl2)
			end

			it "should allow messages that are not restricted" do
				check_can_message(user_tl1)
				check_can_message(user_tl4)
			end

			it "should block messages to users that they are muted by" do
				check_can_message(user_tl1_muted_tl2, expected_status: 422)
			end

			it "should block messages to users that have messages closed" do
				check_can_message(user_tl1_closed, expected_status: 422)
			end

		end

		context "as leader" do

			before do
				sign_in(user_tl4)
			end

			it "should allow messages that are not restricted" do
				check_can_message(user_tl1)
				check_can_message(user_tl2)
			end

			it "should allow messages to users that they are muted by" do
				check_can_message(user_tl1_muted_tl4)
			end

			it "should allow messages to users that have messages closed" do
				check_can_message(user_tl1_closed)
			end
			
		end
	end
end

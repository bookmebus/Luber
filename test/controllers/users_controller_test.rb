require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    User.create!(
      username: 'Rick Sanchez',
      email: 'rick@sanchez.com',
      password: 'password',
      admin: false
    )

    @user = User.where(username: 'Rick Sanchez').take

    User.create!(
      username: 'Morty Sanchez',
      email: 'morty@sanchez.com',
      password: 'password',
      admin: false
    )

    @other_user = User.where(username: 'Morty Sanchez').take
  end

  teardown do
    @user.delete
    @other_user.delete
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { username: @user.username,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'signup path works' do
    get signup_path
    assert_response :success
  end

  test "logged-in user cannot go to user-edit page for other user -- should redirect to root" do
    log_in_as(@other_user)

    puts "before-edit-other-user flash:"
    if defined?(flash)
      puts "Flash: #{flash.to_hash()}" 
    else
      puts "(flash is undefined.)"
    end    

    puts "Getting edit-other-user page for user #{@user.username}..."
    get edit_user_path(@user)
    puts "after edit-other-user flash:"

    if defined? flash
      puts "Flash: #{flash.to_hash()}" 
    else
      puts "(flash is undefined.)"
    end 

    assert (defined? flash == nil)  # should be no flash, just redirect.
    # assert flash.empty?
    assert_redirected_to root_url
  end

  test "logged-in user cannot update-patch other users" do
    # ARG:
    # UsersControllerTest#test_logged-in_user_cannot_update-patch_other_users:
    # NoMethodError: undefined method `flash' for nil:NilClass
    #     test/controllers/users_controller_test.rb:74:in `block in <class:UsersControllerTest>'

    # puts "Pre-login flash:"
    # puts "defined?(flash)=#{defined?(flash)}"
    # if defined?(flash)
    #   puts "Flash is defined."
    #   puts "Flash: #{flash.to_hash()}" 
    # else
    #   puts "(flash is undefined.)"
    # end

    puts "logging in..."
    log_in_as(@other_user)
    puts "Post-login flash:"
    puts "Flash: #{flash.to_hash()}"
    puts "session[:user_id]: #{session[:user_id]}, current username: #{User.find(session[:user_id]).username}"
    puts "Maliciously patching user #{@user.username}:"
    mean_email = "i.am.a.huge.loser@haha.com"
    patch user_path(@user), params: { user: { username: @user.username, email: mean_email } }
    # puts "Flash: #{flash.to_hash()}"
    puts "Victim's new email: #{@user.email}"
    assert @user.email != mean_email
  end
end

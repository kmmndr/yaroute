require 'test_helper'
require_relative 'shared/authentication'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Authentication

  setup do
    @account1 = Account.create(login: 'user1', password: 'secret')
    @account2 = Account.create(login: 'user2', password: 'secret')
  end

  test 'should read own account' do
    get account_url(@account1)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    get account_url(@account1)
    assert_response :success

    disconnect
    get account_url(@account1)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    get account_url(@account1)
    assert_response :forbidden
  end

  test 'should update own account' do
    get account_url(@account1)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    put account_url(@account1), params: { account: { login: 'user1-1' } }
    assert_redirected_to edit_account_path(@account1)

    disconnect
    get account_url(@account1)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    put account_url(@account1), params: { account: { login: 'user1-2' } }
    assert_response :forbidden
  end

  test 'should delete own account' do
    get account_url(@account1)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    delete account_url(@account1)
    assert_response :forbidden

    disconnect

    connect(login: 'user1', password: 'secret')
    delete account_url(@account1)
    assert_redirected_to root_path
  end
end

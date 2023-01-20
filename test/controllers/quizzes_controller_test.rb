require 'test_helper'
require_relative 'shared/authentication'

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  include Authentication

  setup do
    @user1 = Account.create(login: 'user1', password: 'secret').user
    @user2 = Account.create(login: 'user2', password: 'secret').user
  end

  test 'should get index if connected' do
    get quizzes_url
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')

    get quizzes_url
    assert_response :success

    connect(login: 'user2', password: 'secret')
    get quizzes_url
    assert_response :success
  end

  test 'should read own quizzes' do
    quiz = @user1.quizzes.create(title: 'quiz')

    get quiz_url(quiz)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    get quiz_url(quiz)
    assert_response :success

    disconnect
    get quiz_url(quiz)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    get quiz_url(quiz)
    assert_response :forbidden
  end

  test 'should update own quizzes' do
    quiz = @user1.quizzes.create(title: 'quiz')

    get quiz_url(quiz)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    put quiz_url(quiz), params: { quiz: { title: 'new title' } }
    assert_redirected_to quiz_path(quiz)

    disconnect
    get quiz_url(quiz)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    put quiz_url(quiz), params: { quiz: { title: 'unable to change title' } }
    assert_response :forbidden
  end

  test 'should delete own quizzes' do
    quiz1 = @user1.quizzes.create(title: 'quiz')
    quiz2 = @user1.quizzes.create(title: 'quiz')

    get quiz_url(quiz1)
    assert_redirected_to login_path

    connect(login: 'user1', password: 'secret')
    delete quiz_url(quiz1)
    assert_redirected_to quizzes_path

    disconnect
    get quiz_url(quiz2)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    delete quiz_url(quiz2)
    assert_response :forbidden
  end
end

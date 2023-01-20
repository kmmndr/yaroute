require 'test_helper'
require_relative 'shared/authentication'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Authentication

  setup do
    @user1 = Account.create(login: 'user1', password: 'secret').user
    @user2 = Account.create(login: 'user2', password: 'secret').user

    @quiz = @user1.quizzes.create(title: 'quiz')
  end

  test 'should create own games questions' do
    get quiz_url(@quiz)
    assert_redirected_to login_path

    connect(login: 'user2', password: 'secret')
    post quiz_questions_url(@quiz), params: {
      question: {
        title: 'title',
        responses_attributes: {}
      }
    }
    assert_response :forbidden

    disconnect

    connect(login: 'user1', password: 'secret')
    post quiz_questions_url(@quiz), params: {
      question: {
        title: 'title',
        responses_attributes: {}
      }
    }
    question = @quiz.questions.first
    assert_redirected_to edit_question_path(question)

    put question_url(question), params: {
      question: {
        title: 'title',
        responses_attributes: {
          '0' => { title: 'response1', value: true }
        }
      }
    }
    assert_redirected_to edit_question_path(question)
    assert_equal 'response1', question.responses.last.title
    assert_equal true, question.responses.last.value

    put question_url(question), params: {
      question: {
        title: 'title',
        responses_attributes: {
          '0' => { title: 'response1', value: true },
          '1' => { title: 'response2', value: false }
        }
      }
    }
    assert_redirected_to edit_question_path(question)
    assert_equal 'response2', question.responses.last.title
    assert_equal false, question.responses.last.value
  end
end

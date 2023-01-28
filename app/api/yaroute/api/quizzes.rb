module Yaroute
  class API
    class Quizzes < Grape::API
      helpers Grape::Pagy::Helpers

      resource :quizzes do
        desc 'Return a list of quizzes'
        params do
          use :pagy
        end
        get do
          quizzes = current_user.quizzes

          present pagy(quizzes), with: Yaroute::API::Entities::Quiz
        end

        desc 'Return a Quiz'
        get ':id' do
          quiz = Quiz.find(params[:id])
          forbidden! unless current_user.can?(:read_quiz, quiz)

          present quiz, with: Yaroute::API::Entities::Quiz, type: :with_questions
        end

        desc 'Return Quiz games'
        params do
          use :pagy
          optional :include_finished, type: Boolean, default: false
        end
        get ':id/games' do
          quiz = Quiz.find(params[:id])
          forbidden! unless current_user.can?(:read_quiz, quiz)

          games = quiz.games
          games = games.not_finished if params['include_finished'] == false

          present pagy(games), with: Yaroute::API::Entities::Game
        end
      end
    end
  end
end

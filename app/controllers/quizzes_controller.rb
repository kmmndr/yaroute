class QuizzesController < DefaultController
  def index
    @quizzes = Quiz.all
  end
end

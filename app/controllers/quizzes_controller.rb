class QuizzesController < DefaultController
  def index
    forbid! unless current_user.can?(:read_quizzes)

    @pagy, @quizzes = pagy(current_user.quizzes)
  end

  def show
    @quiz = quiz

    forbid! unless current_user.can?(:read_quiz, @quiz)
  end

  def new
    forbid! unless current_user.can?(:create_quiz)

    @quiz = Quiz.new
  end

  def edit
    @quiz = quiz

    forbid! unless current_user.can?(:update_quiz, @quiz)
  end

  def create
    forbid! unless current_user.can?(:create_quiz)

    @quiz = current_user.quizzes.new(quiz_params)

    if @quiz.save
      redirect_to quiz_path(@quiz),
                  notice: t('.notice_created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @quiz = quiz

    forbid! unless current_user.can?(:update_quiz, @quiz)

    if @quiz.update(quiz_params)
      redirect_to quiz_path(@quiz),
                  notice: t('.notice_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    forbid! unless current_user.can?(:delete_quiz, quiz)

    quiz.destroy

    redirect_to quizzes_path,
                notice: t('.notice_deleted')
  end

  private

  def quiz
    @quiz ||= Quiz.find(params[:id])
  end

  def quiz_params
    params.require(:quiz).permit(:title)
  end
end

class QuizzesController < DefaultController
  def index
    @quizzes = Quiz.all
  end

  def show
    @quiz = quiz
  end

  def new
    @quiz = Quiz.new
  end

  def edit
    @quiz = quiz
  end

  def create
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

    if @quiz.update(quiz_params)
      redirect_to quiz_path(@quiz),
                  notice: t('.notice_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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

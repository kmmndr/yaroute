class QuestionsController < DefaultController
  def show
    forbid! unless current_user.can?(:update_quiz, question.quiz)

    @question = question
  end

  def new
    forbid! unless current_user.can?(:update_quiz, quiz)

    @question = quiz.questions.new
    @question.responses.build
  end

  def edit
    forbid! unless current_user.can?(:update_quiz, question.quiz)

    @question = question
    @question.responses.build
  end

  def create
    forbid! unless current_user.can?(:update_quiz, quiz)

    @question = quiz.questions.new(question_params)

    if @question.save
      redirect_to edit_question_path(@question),
                  notice: t('.notice_created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    forbid! unless current_user.can?(:update_quiz, question.quiz)

    @question = question

    if @question.update(question_params)
      redirect_to edit_question_path(@question),
                  notice: t('.notice_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    forbid! unless current_user.can?(:update_quiz, question.quiz)

    question.destroy

    redirect_to questions_path,
                notice: t('.notice_deleted')
  end

  private

  def question
    @question ||= Question.find(params[:id])
  end

  def question_params
    ret = params.require(:question).permit(:title, responses_attributes: [:id, :title, :value])
    ret['responses_attributes']&.delete_if { |_k, v| v&.[]('title').blank? }

    ret
  end

  def quiz
    Quiz.find(params[:quiz_id])
  end
end

class ResponsesController < DefaultController
  def destroy
    question = rresponse.question

    forbid! unless current_user.can?(:update_quiz, question.quiz)

    rresponse.destroy

    redirect_to edit_question_path(question),
                notice: t('.notice_deleted')
  end

  private

  def rresponse
    @rresponse ||= Response.find(params[:id])
  end
end

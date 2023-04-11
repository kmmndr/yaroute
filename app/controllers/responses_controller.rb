class ResponsesController < DefaultController
  def destroy
    question = rresponse.question

    forbid! unless current_user.can?(:update_quiz, question.quiz)

    rresponse.destroy

    redirect_to edit_question_path(question),
                notice: t('.notice_deleted')
  end

  def move_up
    PositionHandler.new(scope: rresponse.question.responses, element: rresponse).move!(:up)

    redirect_to edit_question_path(rresponse.question)
  end

  def move_down
    PositionHandler.new(scope: rresponse.question.responses, element: rresponse).move!(:down)

    redirect_to edit_question_path(rresponse.question)
  end

  private

  def rresponse
    @rresponse ||= Response.find(params[:id])
  end
end

class ResponsesController < DefaultController
  def destroy
    question = rresponse.question
    rresponse.destroy

    redirect_to edit_question_path(question),
                notice: t('.notice_deleted')
  end

  private

  def rresponse
    @rresponse ||= Response.find(params[:id])
  end
end

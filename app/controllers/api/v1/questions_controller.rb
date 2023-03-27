class Api::V1::QuestionsController < ApplicationController
  # GET on /questions
  def index
    @questions = Question.paginate(page: params[:page], per_page: 10)
    render json: @questions, status: :ok
  end

  # GET on /questions/:id
  def show
    begin
      @question = Question.find(params[:id])
      render json: @question, status: :ok
    rescue
      msg = "No such Question exists."
      render json: msg, status: :not_found
    end
  end

  # POST on /questions
  def create
    questionnaire_id = params[:id] unless params[:id].nil?
    # If the questionnaire is being used in the active period of an assignment, delete existing responses before adding new questions
    if AnswerHelper.check_and_delete_responses(questionnaire_id)
      msg = 'You have successfully added a new question. Any existing reviews for the questionnaire have been deleted!'
    else
      msg = 'You have successfully added a new question.'
    end
    num_of_existed_questions = Questionnaire.find(questionnaire_id).questions.size
    question = Object.const_get(params[:question][:type]).create(txt: '', questionnaire_id: questionnaire_id, seq: num_of_existed_questions + 1, type: params[:question][:type], break_before: true)
    if question.is_a? ScoredQuestion
      question.weight = params[:question][:weight]
      question.max_label = 'Strongly agree'
      question.min_label = 'Strongly disagree'
    end
    question.size = '50, 3' if question.is_a? Criterion
    question.size = '50, 3' if question.is_a? Cake
    question.alternatives = '0|1|2|3|4|5' if question.is_a? Dropdown
    question.size = '60, 5' if question.is_a? TextArea
    question.size = '30' if question.is_a? TextField
    begin
      question.save
      render json: question, status: :created
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  # DELETE on /questions/:id
  def destroy
    begin
      question = Question.find(params[:id])
    rescue
      render json: $ERROR_INFO, status: :not_found
    end
    questionnaire_id = question.questionnaire_id
    if AnswerHelper.check_and_delete_responses(questionnaire_id)
      msg = 'You have successfully deleted the question. Any existing reviews for the questionnaire have been deleted!'
    else
      msg = 'You have successfully deleted the question!'
    end
    begin
      question.destroy
      render json: msg, status: :ok
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  # PUT on /questions/:id
  def update
    @question = Question.find(params[:id])
    begin
      @question.update(question_params)
      render json: 'The question was successfully updated.', status: :ok
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  # GET on /questions/types
  def types
    types = Question.distinct.pluck(:type)
    render json: types.to_a, status: :ok
  end

  private
  
  # Only allow a list of trusted parameters through.
  def question_params
    params.permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end
end

class Api::V1::QuestionsController < ApplicationController
  
  # Index method returns the list of questions JSON object
  # GET on /questions
  def index
    @questions = Question.order(:id)
    render json: @questions, status: :ok
  end

  # Show method returns the question object with id - {:id}
  # GET on /questions/:id
  def show
    begin
      @question = Question.find(params[:id])
      render json: @question, status: :ok
    rescue
      render json: $ERROR_INFO.to_s, status: :not_found
    end
  end

  # Create method returns the JSON object of created question
  # POST on /questions
  def create
    questionnaire_id = params[:id] unless params[:id].nil?
    num_of_existed_questions = Questionnaire.find(questionnaire_id).questions.size
    question = Question.create(
      txt: params[:question][:txt],
      questionnaire_id: questionnaire_id,
      seq: num_of_existed_questions + 1,
      question_type: params[:question][:type],
      break_before: true)
    # question = Object.const_get(params[:question][:type]).create(txt: '', questionnaire_id: questionnaire_id, seq: num_of_existed_questions + 1, question_type: params[:question][:type], break_before: true)
    case question.question_type
    when 'Scale'
      question.weight = params[:question][:weight]
      question.max_label = 'Strongly agree'
      question.min_label = 'Strongly disagree'
    when 'Cake', 'Criterion'
      question.weight = params[:question][:weight]
      question.max_label = 'Strongly agree'
      question.min_label = 'Strongly disagree'
      question.size = '50, 3'
    when 'Dropdown'
      question.alternatives = '0|1|2|3|4|5'
      question.size = nil
    when 'TextArea'
      question.size = '60, 5'
    when 'TextField'
      question.size = '30'
    end
    
    begin
      question.save!
      render json: question, status: :created
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity
    end
  end

  # Destroy method deletes the question with id - {:id}
  # DELETE on /questions/:id
  def destroy
    begin
      question = Question.find(params[:id])
    rescue
      render json: $ERROR_INFO.to_s, status: :not_found and return
    end
    begin
      question.destroy
      render json: 'You have successfully deleted the question!', status: :ok and return
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity
    end
  end

  # Delete_all method deletes all the questions and returns the status code
  # DELETE on /questions/delete_all/<questionnaire_id>
  # Endpoint to delete all questions associated to a particular questionnaire.
  def delete_all
    begin
      @questionnaire = Questionnaire.find(params[:id])
      if @questionnaire.questions.size > 0
        @questionnaire.questions.destroy_all
        msg = "All questions for Questionnaire ID:" + params[:id].to_s + " has been successfully deleted!"
        render json: msg, status: :ok
      else
        render json: "No questions associated to Questionnaire ID:" + params[:id].to_s, status: :unprocessable_entity and return
      end
    rescue
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  # Update method updates the question with id - {:id} and returns its JSON object
  # PUT on /questions/:id
  def update
    @question = Question.find(params[:id])
    begin
      @question.update(question_params)
      render json: @question, status: :ok
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity
    end
  end

  # GET on /questions/types
  def types
    types = Question.distinct.pluck(:question_type)
    render json: types.to_a, status: :ok
  end

  private
  
  # Only allow a list of trusted parameters through.
  def question_params
    params.permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end
end

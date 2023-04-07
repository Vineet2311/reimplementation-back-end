class Api::V1::QuestionnairesController < ApplicationController
  
  # GET on /questionnaires
  def index
    @questionnaires = Questionnaire.order(:id)
    render json: @questionnaires, status: :ok
  end
  
  # GET on /questionnaires/:id
  def show
    begin
      @questionnaire = Questionnaire.find(params[:id])
      render json: @questionnaire, status: :ok
    rescue
      msg = "No such Questionnaire exists."
      render json: msg, status: :not_found
    end
  end
  
  # POST on /questionnaires
  # Instructor Id statically defined since implementation of Instructor model is out of scope of E2345.
  def create
    if params[:questionnaire][:name].blank?
      render json: "Questionnaire name cannot be blank.", status: :unprocessable_entity
    end
    begin
      display_type = params[:questionnaire][:type].split('Questionnaire')[0]
      @questionnaire = Questionnaire.new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
      @questionnaire.private = params[:questionnaire][:private] == 'true'
      @questionnaire.name = params[:questionnaire][:name] 
      @questionnaire.instructor_id = 6 # session[:user].id
      @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
      @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
      @questionnaire.questionnaire_type = params[:questionnaire][:type]
      if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
        display_type = (display_type.split(/(?=[A-Z])/)).join('%')
      end
      @questionnaire.display_type = display_type
      @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
      @questionnaire.save
      render json: @questionnaire, status: :created
    rescue StandardError
      msg = $ERROR_INFO
      render json: msg, status: :unprocessable_entity
    end
  end

  # DELETE on /questionnaires/:id
  def destroy
    begin
      @questionnaire = Questionnaire.find(params[:id])
    rescue
      render json: $ERROR_INFO, status: :not_found
    end
    begin
      name = @questionnaire.name
      questions = @questionnaire.questions
      # questions.each do |question|
      #   question.delete
      # end
      unless questions.nil?
        msg = "This questionnaire has questions associated with it. Use this endpoint to delete all questions for the questionnaire: "
        link = "/questions/delete_all/" + @questionnaire.id.to_s
        msg += link
        render json: msg
      else
        @questionnaire.delete
        render json: "The questionnaire \"#{name}\" has been successfully deleted.", status: :ok
      end
    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  # PUT on /questionnaires/:id
  def update
    begin
      # Save questionnaire information
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.update(questionnaire_params)
      # Save all questions
      # unless params[:question].nil?
      #   params[:question].each_pair do |k, v|
      #     @question = Question.find(k)
      #     # example of 'v' value
      #     # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
      #     v.each_pair do |key, value|
      #       @question.send(key + '=', value) unless @question.send(key) == value
      #     end
      #     @question.save
      #   end
      # end
      render json: 'The questionnaire has been successfully updated!', status: :ok
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  # POST on /questionnaires/copy/:id
  def copy
    # instructor_id = session[:user].instructor_id
    instructor_id = 6
    @questionnaire = Questionnaire.copy_questionnaire_details(params, instructor_id)
    render json: "Copy of questionnaire #{@questionnaire.name} has been created successfully.", status: :ok
  rescue StandardError
    render json: 'The questionnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO.to_s, status: :unprocessable_entity
  end

  # GET on /questionnaires/toggle_access/:id
  def toggle_access
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.private = !@questionnaire.private
      @questionnaire.save
      @access = @questionnaire.private == true ? 'private' : 'public'
      render json: "The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ", status: :ok
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def questionnaire_params
    params.permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end
end

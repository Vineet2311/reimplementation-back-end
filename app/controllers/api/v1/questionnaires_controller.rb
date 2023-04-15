class Api::V1::QuestionnairesController < ApplicationController
  
  # GET on /questionnaires
  def index
    begin
      @questionnaires = Questionnaire.order(:id)
      render json: @questionnaires, status: :ok and return
    rescue
      render json: $ERROR_INFO, status: :invalid_request and return
    end
  end
  
  # GET on /questionnaires/:id
  def show
    begin
      @questionnaire = Questionnaire.find(params[:id])
      render json: @questionnaire, status: :ok and return
    rescue
      msg = "No such Questionnaire exists."
      render json: msg, status: :not_found and return
    end
  end
  
  # POST on /questionnaires
  # Instructor Id statically defined since implementation of Instructor model is out of scope of E2345.
  def create
    if params[:name].blank?
      render json: "Questionnaire name cannot be blank.", status: :unprocessable_entity and return
    end
    begin
      @questionnaire = Questionnaire.new(questionnaire_params)
      puts @questionnaire.inspect
      @questionnaire.instructor_id = 6 # session[:user].id
      @questionnaire.display_type = sanitize_display_type(@questionnaire.questionnaire_type)
      @questionnaire.save
      render json: @questionnaire, status: :created and return
    rescue StandardError
      msg = $ERROR_INFO
      render json: msg, status: :unprocessable_entity and return
    end
  end

  # DELETE on /questionnaires/:id
  def destroy
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.delete
    rescue
      render json: $ERROR_INFO, status: :not_found and return
    end
  end

  # PUT on /questionnaires/:id
  def update
    begin
      # Save questionnaire information
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.update(questionnaire_params)
      render json: 'The questionnaire has been successfully updated!', status: :ok and return
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity and return
    end
  end

  # POST on /questionnaires/copy/:id
  def copy
    # instructor_id = session[:user].instructor_id
    instructor_id = 6
    @questionnaire = Questionnaire.copy_questionnaire_details(params, instructor_id)
    render json: "Copy of questionnaire #{@questionnaire.name} has been created successfully.", status: :ok and return
  rescue StandardError
    render json: 'The questionnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO.to_s, status: :unprocessable_entity and return
  end

  # GET on /questionnaires/toggle_access/:id
  def toggle_access
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.private = !@questionnaire.private
      @questionnaire.save
      @access = @questionnaire.private == true ? 'private' : 'public'
      render json: "The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ", status: :ok and return
    rescue StandardError
      render json: $ERROR_INFO, status: :unprocessable_entity and return
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :questionnaire_type, :private, :min_question_score, :max_question_score)
  end

  def sanitize_display_type(type)
    display_type = type.split('Questionnaire')[0]
    if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
      display_type = (display_type.split(/(?=[A-Z])/)).join('%')
    end
    display_type
  end

end

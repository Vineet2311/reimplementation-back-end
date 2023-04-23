class Questionnaire < ApplicationRecord
    has_many :questions, dependent: :restrict_with_error
    belongs_to :instructor
  
    before_destroy :check_for_question_associations

    validate :validate_questionnaire
    validates :name, presence: true
    validates :max_question_score, :min_question_score, numericality: true
  
    DEFAULT_MIN_QUESTION_SCORE = 0  # The lowest score that a reviewer can assign to any questionnaire question
    DEFAULT_MAX_QUESTION_SCORE = 5  # The highest score that a reviewer can assign to any questionnaire question
    DEFAULT_QUESTIONNAIRE_URL = 'http://www.courses.ncsu.edu/csc517'.freeze
    QUESTIONNAIRE_TYPES = ['ReviewQuestionnaire',
                           'MetareviewQuestionnaire',
                           'AuthorFeedbackQuestionnaire',
                           'TeammateReviewQuestionnaire',
                           'SurveyQuestionnaire',
                           'AssignmentSurveyQuestionnaire',
                           'GlobalSurveyQuestionnaire',
                           'CourseSurveyQuestionnaire',
                           'BookmarkRatingQuestionnaire',
                           'QuizQuestionnaire'].freeze
     
    # Maximum possible score calculates maximum possible score based on questions associated to questionnaire                       
    def max_possible_score
      results = Questionnaire.joins('INNER JOIN questions ON questions.questionnaire_id = questionnaires.id')
                             .select('SUM(questions.weight) * questionnaires.max_question_score as max_score')
                             .where('questionnaires.id = ?', id)
      results[0].max_score
    end
  
    # clones the contents of a questionnaire, including the questions and associated advice
    def self.copy_questionnaire_details(params)
      orig_questionnaire = Questionnaire.find(params[:id])
      questions = Question.where(questionnaire_id: params[:id])
      questionnaire = orig_questionnaire.dup
      questionnaire.name = 'Copy of ' + orig_questionnaire.name
      questionnaire.created_at = Time.zone.now
      questionnaire.updated_at = Time.zone.now
      questionnaire.save!
      questions.each do |question|
        new_question = question.dup
        new_question.questionnaire_id = questionnaire.id
        new_question.save!
      end
      questionnaire
    end
  
    # validate the entries for this questionnaire
    def validate_questionnaire
      errors.add(:max_question_score, 'The maximum question score must be a positive integer.') if max_question_score < 1
      errors.add(:min_question_score, 'The minimum question score must be a positive integer.') if min_question_score < 0
      errors.add(:min_question_score, 'The minimum question score must be less than the maximum.') if min_question_score >= max_question_score
  
      results = Questionnaire.where('id <> ? and name = ? and instructor_id = ?', id, name, instructor_id)
      errors.add(:name, 'Questionnaire names must be unique.') if results.present?
    end

    # Check_for_question_associations checks if questionnaire has associated questions or not
    def check_for_question_associations
      if questions.any?
        raise ActiveRecord::DeleteRestrictionError.new(:base, "Cannot delete record because dependent questions exist")
      end
    end


    def as_json(options = {})
        super(options.merge({
                              only: %i[id name private min_question_score max_question_score created_at updated_at questionnaire_type],
                              include: {
                                instructor: { only: %i[name email fullname password role] }
                              }
                            })).tap do |hash|
          hash['instructor'] ||= { id: nil, name: nil }
        end
    end
  end
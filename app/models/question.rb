class Question < ApplicationRecord
    belongs_to :questionnaire # each question belongs to a specific questionnaire
    
    validates :seq, presence: true, numericality: true # sequence must be numeric
    validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # user must define text content for a question
    validates :question_type, presence: true # user must define type for a question
    validates :break_before, presence: true
  
    
    def as_json(options = {})
        super(options.merge({
                              only: %i[questionnaire_id txt weight seq question_type size alternatives break_before min_label max_label created_at updated_at],
                              include: {
                                questionnaire: { only: %i[name private min_question_score max_question_score instructor_id created_at updated_at questionnaire_type] }
                              }
                            })).tap do |hash|
          hash['questionnaire'] ||= { id: nil, name: nil }
        end
    end
  
  end
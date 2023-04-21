class Question < ApplicationRecord
    belongs_to :questionnaire # each question belongs to a specific questionnaire
    
    validates :seq, presence: true, numericality: true # sequence must be numeric
    validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # user must define text content for a question
    validates :question_type, presence: true # user must define type for a question
    validates :break_before, presence: true
  
  end
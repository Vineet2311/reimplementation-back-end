require 'rails_helper'

RSpec.describe Question, type: :model do
    let(:role) {Role.create(name: 'Instructor', parent_id: nil, id: 2, name: 'Instructor_role_test', default_page_id: nil)}
    let(:instructor) { Instructor.create(id: 1234, name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) }
    let(:questionnaire) { Questionnaire.new id:1, name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: instructor.id }
    
  describe "validations" do
    it "is valid with valid attributes" do
      question = Question.new(seq: 1, txt: "Sample question", question_type: "multiple_choice", break_before: true, questionnaire: questionnaire)
      expect(question).to be_valid
    end
    
    it "is not valid without a seq" do
      question = Question.new(txt: "Sample question", question_type: "multiple_choice", break_before: true, questionnaire: questionnaire)
      expect(question).to_not be_valid
    end
    
    it "is not valid with a non-numeric seq" do
      question = Question.new(seq: "one", txt: "Sample question", question_type: "multiple_choice", break_before: true, questionnaire: questionnaire)
      expect(question).to_not be_valid
    end
    
    it "is not valid without a txt" do
      question = Question.new(seq: 1, question_type: "multiple_choice", break_before: true, questionnaire: questionnaire)
      expect(question).to_not be_valid
    end
    
    it "is not valid without a question_type" do
      question = Question.new(seq: 1, txt: "Sample question", break_before: true, questionnaire: questionnaire)
      expect(question).to_not be_valid
    end
    
    it "is not valid without a break_before value" do
      question = Question.new(seq: 1, txt: "Sample question", question_type: "multiple_choice", questionnaire: questionnaire)
      expect(question).to_not be_valid
    end
    
    it "is not valid without a questionnaire" do
      question = Question.new(seq: 1, txt: "Sample question", question_type: "multiple_choice", break_before: true)
      expect(question).to_not be_valid
    end
  end
  
  describe "#delete" do
    it "destroys the question object" do
      instructor.save!
      questionnaire.save!
      question = Question.create(seq: 1, txt: "Sample question", question_type: "multiple_choice", break_before: true, questionnaire: questionnaire)
      expect { question.delete }.to change { Question.count }.by(-1)
    end
  end
end

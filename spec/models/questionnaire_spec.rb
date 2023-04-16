require 'rails_helper'
describe Questionnaire, type: :model do
  let(:questionnaire) { Questionnaire.new id:1, name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: 'xyz', private: 0, max_question_score: 20, instructor_id: 1234 }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let(:question1) { create(:question, questionnaire: questionnaire2, weight: 1, id: 1) }
  let(:question2) { create(:question, questionnaire: questionnaire2, weight: 2, id: 2) }
  describe '#name' do
    it 'returns the name of the Questionnaire' do
      expect(questionnaire.name).to eq('abc')
    end

    it 'Validate presence of name which cannot be blank' do
      questionnaire.name = '  '
      expect(questionnaire).not_to be_valid
    end
  end

  describe '#instructor_id' do
    it 'returns the instructor id' do
      expect(questionnaire.instructor_id).to eq(1234)
    end
  end

  describe '#maximum_score' do
    it 'validate maximum score' do
      expect(questionnaire.max_question_score).to eq(10)
    end

    it 'validate maximum score is integer' do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = 'a'
      expect(questionnaire).not_to be_valid
    end

    it 'validate maximum should be positive' do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = -10
      expect(questionnaire).not_to be_valid
      questionnaire.max_question_score = 10
    end

    it 'validate maximum should be bigger than minimum' do
      expect(questionnaire.min_question_score).to eq(0)
      questionnaire.min_question_score = 10
      expect(questionnaire).not_to be_valid
      questionnaire.min_question_score = 0
    end
  end

  describe '#minimum_score' do
    it 'validate minimum score' do
      questionnaire.min_question_score = 5
      expect(questionnaire.min_question_score).to eq(5)
    end

    it 'validate minimum should be smaller than maximum' do
      expect(questionnaire.min_question_score).to eq(0)
      questionnaire.min_question_score = 10
      expect(questionnaire).not_to be_valid
      questionnaire.min_question_score = 0
    end
  end


  it 'allowing calls from copy_questionnaire_details' do
    allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
    allow(Question).to receive(:where).with(questionnaire_id: '1').and_return([Question])
  end

  


  # describe '#delete' do
  #   it 'deletes all dependent objects and itself' do
  #     allow(questionnaire2).to receive(:questions).and_return([question1, question2])
  #     allow(questionnaire2).to receive(:assignments).and_return([])
  #     #allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(questionnaire_node)
  #     expect(questionnaire2.delete).to be_truthy
  #   end
  #   context 'when there are associated assignments' do
  #     it 'raises an error' do
  #       allow(questionnaire2).to receive(:questions).and_return([question1, question2])
  #       allow(questionnaire2).to receive(:assignments).and_return([assignment])
  #       allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(questionnaire_node)
  #       expect { questionnaire2.delete }.to raise_error(RuntimeError)
  #     end
  #   end
  #end

  # describe '.copy_questionnaire_details' do

  #   it 'creates a copy of the questionnaire with the given instructor_id' do
      
  #     puts(questionnaire.id)
  #     copied_questionnaire = Questionnaire.copy_questionnaire_details( { id: questionnaire.id}, questionnaire.instructor_id)
  #     expect(copied_questionnaire.instructor_id).to eq(questionnaire.instructor_id)
  #     expect(copied_questionnaire.name).to eq("Copy of #{questionnaire.name}")
  #     expect(copied_questionnaire.created_at).to be_within(1.second).of(Time.zone.now)
  #   end

  #   it 'creates a copy of all questions belonging to the original questionnaire' do
  #     copied_questionnaire = described_class.copy_questionnaire_details({ id: orig_questionnaire.id }, instructor_id)
  #     expect(copied_questionnaire.questions.count).to eq(2)
  #     expect(copied_questionnaire.questions.first.title).to eq(question1.title)
  #     expect(copied_questionnaire.questions.second.title).to eq(question2.title)
  #   end
  # end



  
end
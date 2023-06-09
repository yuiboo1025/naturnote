require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe 'モデルのテスト' do
    it "有効なgenreの場合は保存されるか" do
      expect(build(:genre)).to be_valid
    end

    context "空白のバリデーションチェック" do
      it "genre_nameが空白の場合にエラーメッセージが返ってくるか" do
        # genre_nameにgenre_nameカラムを空で保存したものを代入
        genre_name = build(:genre, genre_name: nil)
        # バリデーションチェックを行う
        genre_name.valid?
        # genre_nameカラムでエラーが出て、フラッシュメッセージに"を入力してください"が含まれているか？
        expect(genre_name.errors[:genre_name]).to include("を入力してください")
      end
    end
  end
  
  describe 'アソシエーションのテスト' do
    let(:association) do
      described_class.reflect_on_association(target)
    end

    context 'Wineモデルとの関係' do
      let(:target) { :wines }

      it 'Wineとの関連付けはhas_manyであること' do
        expect(association.macro).to eq :has_many
      end
    end
  end
  
end
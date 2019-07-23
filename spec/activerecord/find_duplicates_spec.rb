RSpec.describe Activerecord::FindDuplicates do
  it do
    user_1 = User.create!(email: 'a@a.com')
    user_2 = User.create!(email: 'a@a.com')
    user_3 = User.create!(email: 'b@b.com')
    expect(User.find_duplicates(on: :email)).to eq [user_1, user_2]
  end
end

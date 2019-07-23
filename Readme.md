# Activerecord::FindDuplicates

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'activerecord-find_duplicates'
```

## Usage

General usage is:
```ruby
Model.find_duplicates(on: attr_name)
```

You can pass a minimum number to be considered a duplicate (default is 2) with `min:`.

Example: To find all user records that have a duplicate email address:
```ruby
User.find_duplicates(on: :email)
# => [#<User:0x000055e7916ff3c8 id: 1, email: "a@a.com">,
      #<User:0x000055e7916ff1e8 id: 2, email: "a@a.com">]
```

Often it is useful to group by the duplicate value, making the value the key and the set of records sharing that key as the value:
```ruby
User.find_duplicates(on: :email).group_by(&:email)
# => {"a@a.com"=>
  [#<User:0x000055cc1915f0c8 id: 1, email: "a@a.com">,
   #<User:0x000055cc1915ef38 id: 2, email: "a@a.com">]}
```

You can also chain it on other relations. For example, to find all duplicates *except* those with a null value:
```ruby
User.where('email is not null').find_duplicates(on: :email)
```

## Possible use: clean up data before adding a unique data

You realize that a certain column should be unique but actually contains duplicate values. Even though you had a uniqueness validation on the model:
```ruby
validates :email, uniqueness: true
```
, this is subject to race conditions. The only sure way to prevent duplicate values on a column is to add a unique index/constraint and let your *database* engine enforce the constraint.

But before you can add a migration that adds that index, you have to remove all duplicates or you will get:
```
PG::UniqueViolation: ERROR:  could not create unique index "index_users_on_email"
DETAIL:  Key (email)=(user@example.com) is duplicated.
```

You might do something like this to delete all but the most recent record for each distinct value:

```ruby
    User.where('email is not null').find_duplicates(on: :email).group_by(&:email).each do |email, users|
      users.sort_by(&:created_at).each.with_index do |user, i|
        user.destroy unless i == users.length - 1
      end
    end
```

and something like this to prevent such duplicates from being added again in the future:

```ruby
    change_table :users do |t|
      t.remove_index name: :index_users_on_email
      t.index :email, unique: true
    end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/activerecord-find_duplicates.

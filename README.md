Surus
=====

[![Build Status](https://travis-ci.org/jackc/surus.svg?branch=master)](https://travis-ci.org/jackc/surus)

# Description

Surus adds PostgreSQL specific functionality to ActiveRecord. It adds
helper methods for searching PostgreSQL arrays and hstores.
It also can control PostgreSQL synchronous commit behavior. By relaxing
PostgreSQL's durability guarantee, transaction commit rate can be increased by
50% or more. It can also directly generate JSON in PostgreSQL which can be
substantially faster than converting ActiveRecord objects to JSON.

# Installation

    gem install surus

Or add to your Gemfile. This version of Surus only works on Rails 4.2+.

    gem 'surus'

## Rails 3

Use the 0.4 line for Rails 3

    gem 'surus', '~> 0.4.2'

# JSON

PostgreSQL 9.2 added `row_to_json` and `array_to_json` functions. These
functions can be used to build JSON very quickly. Unfortunately, they are
somewhat cumbersome to use. The `find_json` and `all_json` methods are easy to
use wrappers around the lower level PostgreSQL functions that closely mimic
the Rails `to_json` interface.

    User.find_json 1
    User.find_json 1, columns: [:id, :name, :email]
    Post.find_json 1, include: :author
    User.find_json(user.id, include: {posts: {columns: [:id, :subject]}})
    User.all_json
    User.where(admin: true).all_json
    User.all_json(columns: [:id, :name, :email], include: {posts: {columns: [:id, :subject]}})
    Post.all_json(include: [:forum, :post])

# Hstore

Hstores can be searched with helper scopes.

    User.hstore_has_pairs(:properties, "favorite_color" => "green")
    User.hstore_has_key(:properties, "favorite_color")
    User.hstore_has_all_keys(:properties, "favorite_color", "gender")
    User.hstore_has_any_keys(:properties, "favorite_color", "favorite_artist")

Hstore is a PostgreSQL extension. You can generate a migration to install it.

    rails g surus:hstore:install
    rake db:migrate

Even though the underlying hstore can only use strings for keys and values
(and NULL for values) Surus can successfully maintain type for integers,
floats, bigdecimals, dates, and any value that YAML can serialize. It does
this by storing an extra key value pair (or two) to maintain type information.

Because it falls back to YAML serialization for complex types, this means that
nested data structures can be serialized to an hstore. In other words, any
hash that can be serialized with the normal Rails YAML serialization can be
serialized with Surus.

**Serialize example (Rails 3+)**:

```ruby
class User < ActiveRecord::Base
  serialize :settings, Surus::Hstore::Serializer.new
end
```

**Store example (Rails 4+)**:

```ruby
class User < ActiveRecord::Base
  store :settings, accessors: [:session_timeout], coder: Surus::Hstore::Serializer.new
end
```

# Array

Arrays can be searched with helper scopes.

    User.array_has(:permissions, "admin")
    User.array_has(:permissions, "manage_accounts", "manage_users")
    User.array_has_any(:favorite_integers, 7, 11, 42)

# Synchronous Commit

PostgreSQL can trade durability for speed. By disabling synchronous commit,
transactions will return before the data is actually stored on the disk. This
can be substantially faster, but it entails a short window where a crash
could cause data loss (but not data corruption). This can be enabled for an
entire session or per transaction.

    User.synchronous_commit # -> true

    User.transaction do
      User.synchronous_commit false
      @user.save
    end # This transaction can return before the data is written to the drive

    # synchronous_commit returns to its former value outside of the transaction
    User.synchronous_commit # -> true

    # synchronous_commit can be turned off permanently
    User.synchronous_commit false

Read more in the [PostgreSQL asynchronous commit documentation](http://www.postgresql.org/docs/9.1/interactive/wal-async-commit.html).

# Benchmarks

JSON generation is with all_json and find_json is substantially faster than to_json.

    jack@hk-47~/dev/surus$ ruby -I lib -I bench bench/json_generation.rb
    Generating test data... Done.
                                                                  user     system      total        real
    find_json: 1 record 500 times                             0.140000   0.010000   0.150000 (  0.205195)
    to_json:   1 record 500 times                             0.240000   0.010000   0.250000 (  0.287435)
    find_json: 1 record with 3 associations 500 times         0.480000   0.010000   0.490000 (  0.796025)
    to_json:   1 record with 3 associations 500 times         1.130000   0.050000   1.180000 (  1.500837)
    all_json:  50 records with 3 associations 20 times        0.030000   0.000000   0.030000 (  0.090454)
    to_json:   50 records with 3 associations 20 times        1.350000   0.020000   1.370000 (  1.710151)

Disabling synchronous commit can improve commit speed by 50% or more.

    jack@moya:~/work/surus$ ruby -I lib -I bench bench/synchronous_commit.rb
    Generating random data before test to avoid bias... Done.

    Writing 1000 narrow records
                                         user     system      total        real
    enabled                          0.550000   0.870000   1.420000 (  3.025896)
    disabled                         0.700000   0.580000   1.280000 (  1.788585)
    disabled per transaction         0.870000   0.580000   1.450000 (  2.072150)
    enabled / single transaction     0.700000   0.330000   1.030000 (  1.280455)
    disabled / single transaction    0.660000   0.340000   1.000000 (  1.252301)

    Writing 1000 wide records
                                         user     system      total        real
    enabled                          1.030000   0.870000   1.900000 (  3.559709)
    disabled                         0.930000   0.780000   1.710000 (  2.259340)
    disabled per transaction         0.970000   0.850000   1.820000 (  2.478290)
    enabled / single transaction     0.890000   0.500000   1.390000 (  1.693629)
    disabled / single transaction    0.820000   0.450000   1.270000 (  1.554767)

Many more benchmarks are in the bench directory. Most accept parameters to
adjust the amount of test data.

## Running the benchmarks

1. Create a database
2. Configure bench/database.yml to connect to it.
3. Load bench/database_structure.sql into your bench database.
4. Run benchmark scripts from root of gem directory (remember pass ruby
   the include paths for lib and bench)



# License

MIT

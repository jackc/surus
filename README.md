Surus
=====

# Description

Surus extends ActiveRecord with PostgreSQL specific functionality. It includes
hstore and array serializers and helper scopes. It also includes a helper to
control PostgreSQL synchronous commit behavior

# Installation

    gem install surus
    
    or add to your Gemfile
    
    gem 'surus'

# Hstore

Hashes can be serialized to an hstore column. hstore is a PostgreSQL key/value
type that can be indexed for fast searching.

    class User < ActiveRecord::Base
      serialize :properties, Surus::Hstore::Serializer.new
    end
    
Even though the underlying hstore can only use strings for keys and values
(and NULL for values) Surus can successfully maintain type for integers,
floats, bigdecimals, and dates. It does this by storing an extra key
value pair (or two) to maintain type information.

Hstores can be searched with helper scopes.

    User.hstore_has_pairs(:properties, "favorite_color" => "green")
    User.hstore_has_key(:properties, "favorite_color")
    User.hstore_has_all_keys(:properties, "favorite_color", "gender")
    User.hstore_has_any_keys(:properties, "favorite_color", "favorite_artist")
    
    
Read more in the [PostgreSQL hstore documentation](http://www.postgresql.org/docs/9.1/static/hstore.html).
    
# Array

Ruby arrays can be serialized to PostgreSQL arrays. Surus includes support
for text, integer, float, and decimal arrays.

    class User < ActiveRecord::Base
      serialize :permissions, Surus::Array::TextSerializer.new
      serialize :favorite_integers, Surus::Array::IntegerSerializer.new
      serialize :favorite_floats, Surus::Array::FloatSerializer.new
      serialize :favorite_decimals, Surus::Array::DecimalSerializer.new
    end
    
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
    
# License

MIT

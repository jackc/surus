Surus
=====

# Description

Surus extends ActiveRecord with PostgreSQL specific functionality. It includes
hstore and array serializers and helper scopes.

# Installation

    gem install surus
    
    or add to your Gemfile
    
    gem 'surus'

# Hstore

Hashes can be serialized to an hstore column.

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

# License

MIT

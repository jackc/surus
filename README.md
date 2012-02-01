Surus
=====

# Description

Surus extends ActiveRecord with PostgreSQL specific functionality. At the
moment this is limited to hstore.

# Installation

    gem install surus

# Hstore

Hashes can be serialized to an hstore column.

    class User < ActiveRecord::Base
      serialize :properties, Hstore::Serializer.new
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

# License

MIT

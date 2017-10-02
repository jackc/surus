# 0.7.0 (October 2, 2017)

* Support JSON has_many :though relationships (Peter Schilling)

# 0.6.5 (May 5, 2017)

* Qualify column references with table names (Zach Schneider)
* Tested against Rails 5.1 and Ruby 2.4
* Dropped Rails 4.1 and Ruby 2.1 support

# 0.6.4 (November 5, 2016)

* Fix has_and_belongs_to_many scope with non-standard primary key (Nick Inhofe)

# 0.6.3 (May 14, 2016)

* Gemspec allows Rails 5

# 0.6.2 (November 19, 2015)

* Prefix column name with table names in query conditions (Michał Krzyżanowski)

# 0.6.1 (July 18, 2015)

* Fix all_json and prepared statements (mathieumahe)

# 0.6.0 (May 15, 2015)

* find_json and all_json support has_one associations (Mathieu Dumont)
* find_json and all_json preserve "select" scope unless columns or include arguments are present

# 0.5.1 (August 29, 2014)

* Quote assocation column names
* Omitting 'as' results in syntax error with belongs to relationship (Michael J. Cohen)
* Fix (find|all)_json when scope chain has joins with ambiguous names

# 0.5.0 (August 19, 2013)

* Rails 4 support

# 0.4.2 (June 21, 2013)

* Make pg a development dependency to allow usage with JRuby
* Added migration support for hstore (Justin Talbott)
* Added migration support for json
* Make activerecord dependency ~> 3.1 to keep incompatible version of Surus from being used with Rails 4
* Updated docs to mention Rails 4 branch

# 0.4.1 (February 27, 2013)

* Fix array_has and array_has_any with varchar[]

# 0.4.0 (February 22, 2013)

* Added JSON generation with find_json and all_json

# 0.3.2 (March 10, 2012)

* No changes. Had to bump version to get around partially failed upload to RubyGems.org.

# 0.3.1 (March 10, 2012)

* Added generator for hstore migration (Tad Thorley)

# 0.3.0 (February 16, 2012)

* Can now round-trip any value YAML can dump and load as an hstore key or value

# 0.2.0 (February 4, 2012)

* Added symbol to types that are successfully round-tripped as hstore keys and values
* Added synchronous_commit support
* Added benchmarks
* Added rdoc documentation and expanded readme.

# 0.1.0 (February 2, 2012)

* Added array serializers
* Added array scope helpers
* Moved everything into Surus namespace
* Add true and false to types that are successfully round-tripped as hstore keys and values
* Changed default test database name to surus_test

# 0.0.1 (January 31, 2012)

* Initial release

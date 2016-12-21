# Hasty Archive
Hasty Archive is an Object-relational mapping (ORM) built in ruby.
Classes are mapped directly to database tables through their class name by inheriting from the SQLObject class, then calling the finalize! class method.

```ruby
class Chicken < SQLObject
  finalize!
end
```
### Libraries
- sqlite3
- active_support: inflector

### Features
Hasty Archive includes numerous useful features and methods for database querying.
- **::table_name**
- **::all**
- **::first**
- **::last**
- **::find(id)**
- **::find_by(search_field)**
- **::where**
- **::validates**
- **::has_many**
- **::belongs_to**
- **::has_one_through**
- **#save**
- **#save!**
- **#errors**

### Demo

1. Clone or save this repo.
2. Run bundle install
3. Run pry or irb
4. load 'demo.rb'
5. Try out all the functions!
6. You can modify the demo.rb file to try out different validations

### Details

#### Find and Find_by

Find will only take an id field and will always return nil or a single SQLObject. Find_by takes a key value pair and will return an empty array or an array of SQLObjects.

```ruby
  Chicken.find(1)
  Chicken.find_by(name: "Josh")
```

#### Where
Where can either take an options hash, or take a string with sql.
```ruby
Chicken.where(name: "Josh", owner_id: 3)
Chicken.where("name = 'Josh' AND owner_id = 3")
```

#### Validations

Currently, Hasty Archive supports three types of validations: presence, uniqueness and length. Apply validations by calling the class method validates in the class.

```ruby
class Chicken < SQLObject
  validates :name,
    presence: true,
    length: { minimum: 5, maximum: 16 },
    uniqueness: true

  finalize!
end
```
Validations are implemented through a separate Validator class. The ::validates method creates a new instance class.

```ruby
def validates(*col_names, options)
  validations.push(Validator.new(col_names, options))
end
```
The validator class then runs through each validation as needed. On error, the method will push an error onto the errors array. The SQLObject is valid if there are no errors.
```ruby
def is_valid?(sql_object)
  verify_validations(sql_object)
  return errors.empty?
end
```


#### Associations
Apply has_many, belongs_to, and has_one_through by calling the method in the class. has_many and belongs_to takes an optional class_name, foreign_key, and primary_key in an options hash. Has one through takes name, through_name, source_name as required arguments.
```ruby
class Chicken < SQLObject
  belongs_to :owner, class_name: 'Farmer'
  has_one_through :farm, :owner, :farm

  finalize!
end

class Farmer < SQLObject
  has_many :cows, foreign_key: :owner_id
  has_many :chickens, foreign_key: :owner_id
  belongs_to :farm

  finalize!
end
```

#### Saving
Save will call the #valid? method on the current SQLObject. If this returns true it will call save! and return true. Otherwise, the method will return false and users can access the errors by calling #errors.

```ruby
chicken = Chicken.new(name: "Chicken")
chicken.save
# returns false
chicken.errors
# returns ["state cannot be blank"]
```

Save! will decide to either create or update based on the presence of the id field.

### Future Features
- More Validations
- Has Many Through
- includes
- joins

# MethodStruct

[![Build Status](https://travis-ci.org/basecrm/method_struct.png?branch=master)](https://travis-ci.org/basecrm/method_struct)

Facilitates extracting large methods into objects - see Usage.
For a more in-depth treatment of the refactoring see
http://sourcemaking.com/refactoring/replace-method-with-method-object

## Installation

Add this line to your application's Gemfile:

    gem 'method_struct'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install method_struct

## Usage

Say you have this:

```ruby
class UsersController
  def create
    User.create(:email => params[:email], :name => params[:name])
    Mailer.registration_email(params[:email]).deliver
  end
end
```

You can change it into this:

```ruby
class Registrator < MethodStruct.new(:email, :name)
  def call
    create_user!
    send_email!
  end

  private
  def create_user!
    User.create(:email => email, :name => name)
  end

  def send_email!
    Mailer.registration_email(:email).deliver
  end
end

class UsersController
  def create
    Registrator.call(params[:email], params[:name])
    # Or
    Registrator.call(:email => params[:email], :name => params[:name])
    # Or - thanks to ruby changing [] into .call
    Registrator[params[:email], params[:name]]
  end
end
```

You can also specify a different method name like so:

```ruby
class Registrator < MethodStruct.new(:email, :name, :method_name => :register)
  def register
    # ...
  end
end

class UsersController
  def create
    Registrator.register(params[:email], params[:name])
  end
end
```

You can use `:require_all => true` if you want to verify that all arguments
have been specified or `:require_presence => true` to verify that all arguments
are non-nil. Global defaults for these options can be changed like so:

```ruby
MethodStruct::Defaults.set(
  :require_presence => true,
  :method_name => :do_it
)
```

Method struct currently also supports a `do` syntax, but it is discouraged (and may get depracated)
due to odd constant scoping. Example:

```ruby
Registrator = MethodStruct.new(:email, :name) do
  REGISTRATION_PATH = "/register" # this is now a top-level constant

  def call
    ...
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

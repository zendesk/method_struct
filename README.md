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

    class UsersController
      def create
        User.create(:email => params[:email], :name => params[:name])
        Mailer.registration_email(params[:email]).deliver
      end
    end

You can change it into this:

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
      end
    end

You can also specify a different method name like so:

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

One hopes the benefits will be more obvious for more complex methods

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Aygabtu - all your GETs are belong to us!

Aygabtu lets you write simplistic feature tests quickly.

It provides a DSL on top of rspec and capybara that can be used to enumerate a rails application's routes and auto-generate feature tests.
These tests are very easy to set up, but they can only assert simple things like "does the page actually get rendered?".

Features that are valuable and profitable enough should still be written conventionally, aygabtu is not a silver bullet for feature tests. Since aygabtu embraces rspec, it should be simple to migrate a feature from using aygabtu to a full-blown rspec/capybara feature.

Aygabtu uses code generation under the hood, but tries to be guard-friendly: Guard should be able to re-run failed examples by line number in many situations.

## Installation

Add this line to your application's Gemfile:

    group :test do
      gem 'aygabtu', require: false
    end

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aygabtu

## Usage

Create `spec/features/aygabtu_features_spec.rb` with the following content:

```
require 'spec_helper' # or whatever is necessary to initialize your Rails app and configure rspec and capybara

require 'aygabtu/rspec'

describe "Aygabtu generated features", type: :feature do
  include Aygabtu::RSpec.example_group_module

  def aygabtu_assertions
    aygabtu_assert_status_success
    aygabtu_assert_not_redirected_away
  end

  # particular example configurations go here

  # must be at the very bottom
  remaining.requiring_anything(false).pass
  remaining.pend "pending because route needs segments passed"
end
```

This will get you up and running with

* an example for every route that does not require any dynamic segment to be passed, which visits that route and asserts the HTTP status is 200 and the url did not change (because of a redirect)
* a pending example for every other route

Continue reading "Scope, scope chains and actions" for the fundamental notions.

## Features

### Scope, scope chains and actions

This is crucial to understand. Be sure not to miss this section.

**Scopes** define rules and filters to be applied to routes. When an **action** is called for a scope, it affects all routes filtered by the scope and uses rules defined by it. Basic example:

```
controller(:posts).pend "TBD. Testing posts needs XY done before this can be tackled."
```

creates pending examples for every route routing into `PostsController`. Here, `controller(:posts)` is the scope, and `pend` is the action.

Scopes can be **chained**. If this reminds you of ActiveRecord query chains, you are exactly on the right track here. For example,

```
namespace(:web).controller(:posts)
```

is a scope matching all routes routing into `Web::PostsController`.

Aygabtu keeps a **current scope**. You can call any action inside an example group, this will call that action on the current scope. Calling

Scopes can be **nested**. Call the last method of a scope chain with a block like this:

```
namespace(:web).controller(:posts) do
  before do
    ...
  end

  pass(some_param: "value")
end
```

This creates a new example group (exactly what happens when you call `context` in rspec). You can use this to set up test preconditions in a `before` block, as indicated in the example above. Inside this context,

* the result of the scope chain (`namespace(:web).controller(:posts)` in the above example) is the new current scope
* thus, calling an action is affected by that scope
* calling a scope method *chains* onto the current scope

To explain the last point,

```
namespace(:web) do
  controller(:posts).pend "TBD. Testing posts needs XY done before this can be tackled."
end
```

would create pending examples for all routes routing into `Web::PostsController`.

### Treats nonsensical conditions as errors

When you apply an action to a scope which does not match any route, most probably you made a mistake, and aygabtu treats it that way. This avoids your aygabtu examples diverging from your application.

Some scopes can break up into multiple scopes, and each component must match a route by itself. See the documentation for the individual scope methods.

In many situations you can see aygabtu raising an exception when you try to do things that do not make sense. Aygabtu prefers yelling at you over you yelling at your computer because some weird conditions create unexplicable behaviour that is hard to debug.

Aygabtu keeps track of actions applied to routes, and treats it as an error when

* a route is hit with two different actions (having both a pending example and a regular one for the same route means you probably missed something)
* a route is hit twice with the same action (which forces you to structure your examples and keep things tidy)

As an exception, you can create multiple regular examples for the same route using `pass`. Please consider if using a vanilla rspec/capybara spec would make more sense in that case.

## List of actions

### `pass`

Creates examples for every matching route, passing data for dynamic URL segments and query string parameters.

Data can be passed as an argument to `pass` and using the `passing` scope method. The deeper the nesting or chaining (the call to `pass` is always the deepest), the higher the precedence.

Data is passed as a hash, where keys are parameter or dynamic segment names, and values are passed after being converted to strings. Symbol values are special: they are interpreted as method names within the example and used to obtain the actual value. Example:

```
controller(:posts) do
  def post_id
    post = Post.create
    post.id
  end

  pass(id: :post_id)
end
```

### `pend`

Creates a pending example for every matching route. Requires you to indicate a reason as the only parameter. This is a good thing since it means the reason for the decision to pend the example(s) is kept in the source.

Pending examples are disabled in such a way that before hooks are not invoked. May actually use RSpec's skip mechanism instead of pending.
Unfortunately, the reason does not show up in the output.

### `ignore`

No example whatsoever will be generated for matching routes. Requires you to indicate a reason just like `pend`.

As a short-hand, you can use `covered!` instead of `ignore` for routes that need no aygabtu example because somebody has already written a regular feature test that covers them (but please be honest to yourself and don't use `covered!` just because it allows you to omit the reason).

## List of scope methods

### `controller` and `namespace`

These go hand in hand, and are best explained by an example. Say you have controllers

1. `A::B::FooController`
2. `A::BarController`
3. `FooController` (or, more precisely, `::FooController`)

then

* `namespace(:a)` (or `namespace('a')`) matches (1) and (2)
* `namespace('a/b')` matches only (1)
* `namespace('a/bar')` matches no of them
* `controller('foo')` matches (1) and (3)

### `named`

`named(:posts)` matches the route named `posts` (which you would link to using `posts_path` or `posts_url`).

When called with multiple arguments, the resulting scope breaks up internally, and for each name, a route must match. So `named(:posts, :comments)` is just a short-hand for using `named` twice.

### `passing`

When the `pass` action is used, the scope uses the given parameters for building the URLs. See the documentation for the `pass` action.

### `remaining` and `requiring`

`remaining` matches routes not used with any action yet. `requiring` matches routes which need the given route segments.

You can use them to build constructs like this:

```
controller(:posts) do
  # let's assume this has a simple resource(:posts) route declaration

  def posts_id
    ...
  end

  requiring(:id).passing(id: :posts_id).pass # creates examples for all member routes
  remaining.pass # creates examples for all collection routes (:index and :new)
end
```

You can also use `remaining` at the very bottom to pend all remaining routes, see the initial example.

### `requiring_anything`

* `requiring_anything(true)` matches routes which have a dynamic segment.
* `requiring_anything(false)` matches routes which have no dynamic segment.

## Caveats

* With the standard assertions configured, Aygabtu will happily accept a rails error page as long as the HTTP status is 200. Somebody should find out how these can be reliably told apart from regular result pages, so the default assertions can be improved. Until then, you should try to add an assertion that checks for a common element on pages, like a footer element.

## Missing features

* tests, preferrably against different versions of Rails, RSpec and capybara
* support for example metadata (you can have it with a conventional `context` any time)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/aygabtu/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

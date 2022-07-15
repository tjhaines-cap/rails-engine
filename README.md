# Rails Engine

This application exposes data through an API about merchants and items.

### Versions

Ruby: 2.7.2
Rails: 5.2.6

### Installation

```
git clone https://github.com/tjhaines-cap/rails-engine
cd rails-engine
bundle install
rails db:{drop,create,migrate,seed}
rails db:shema:dump
```

### Example Endpoints

To get all merchant information
```
get "/api/v1/merchants"
```

To search for a merchant by name
```
get "/api/v1/merchants/find?name=Turing"
```
